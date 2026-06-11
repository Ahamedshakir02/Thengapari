/** PDF generation: homeowner harvest report + GST-compliant B2B invoice. */
import {FieldValue} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import PDFDocument from "pdfkit";
import {db, storage} from "./lib";

/** Render a PDFKit document to a Buffer. */
function renderPdf(draw: (doc: PDFKit.PDFDocument) => void): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({size: "A4", margin: 48});
    const chunks: Buffer[] = [];
    doc.on("data", (c: Buffer) => chunks.push(c));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);
    draw(doc);
    doc.end();
  });
}

/** Upload a PDF buffer to Storage and return a long-lived download URL. */
async function upload(path: string, buffer: Buffer): Promise<string> {
  const file = storage.bucket().file(path);
  await file.save(buffer, {contentType: "application/pdf"});
  const [url] = await file.getSignedUrl({
    action: "read",
    expires: "2100-01-01",
  });
  return url;
}

/** Homeowner-facing harvest report. */
export const generateHarvestReport = onCall(async (request) => {
  const jobId = request.data.jobId as string;
  if (!jobId) throw new HttpsError("invalid-argument", "jobId required.");
  const jobSnap = await db.collection("jobs").doc(jobId).get();
  if (!jobSnap.exists) throw new HttpsError("not-found", "Job not found.");
  const job = jobSnap.data()!;
  const yieldSnap = await db.doc(`jobs/${jobId}/yieldData/current`).get();
  const y = yieldSnap.data() ?? {};

  const buffer = await renderPdf((doc) => {
    doc.fontSize(20).text("ThengaPari — Harvest Report", {align: "left"});
    doc.moveDown(0.5);
    doc.fontSize(10).fillColor("#666").text(`Job ${jobId}`);
    doc.moveDown();
    doc.fillColor("#000").fontSize(12);
    doc.text(`Property: ${job.address ?? job.district ?? "—"}`);
    doc.text(`Crops: ${(job.cropTypes ?? []).join(", ")}`);
    doc.text(`Total yield: ${y.totalKg ?? job.actualYieldKg ?? 0} kg`);
    doc.text(
      `Grades — A: ${y.gradeA ?? 0}  B: ${y.gradeB ?? 0}  Tender: ${y.tender ?? 0}`
    );
    doc.text(`Estimated earnings: ₹${y.estimatedValue ?? job.earningsAmount ?? 0}`);
    doc.moveDown();
    doc.fontSize(10).fillColor("#666").text(
      "Fresh produce supervised on-site by a ThengaPari student site manager."
    );
  });

  const url = await upload(`harvest_reports/${jobId}.pdf`, buffer);
  await jobSnap.ref.update({reportUrl: url});
  return {pdfUrl: url};
});

/** Build + store the GST invoice for an order; returns the URL. */
export async function buildInvoicePdf(orderId: string): Promise<string> {
  const orderSnap = await db.collection("b2b_orders").doc(orderId).get();
  if (!orderSnap.exists) throw new Error("Order not found");
  const o = orderSnap.data()!;
  const buyer = (await db.collection("b2b_buyers").doc(o.buyerId).get()).data();

  const buffer = await renderPdf((doc) => {
    doc.fontSize(18).text("Tax Invoice", {align: "right"});
    doc.fontSize(10).fillColor("#666").text(`INV-${orderId}`, {align: "right"});
    doc.moveDown();
    doc.fillColor("#000").fontSize(11);
    doc.text("ThengaPari Agri Pvt Ltd · GSTIN 32AABCT1234T1Z2");
    doc.moveDown(0.5);
    doc.text(`Buyer: ${buyer?.businessName ?? "—"}`);
    doc.text(`Buyer GSTIN: ${buyer?.gstNumber ?? "—"}`);
    doc.moveDown();
    const taxable = (o.totalAmount as number) ?? 0;
    doc.text(
      `${o.cropType} (${o.grade}) — ${o.quantity} ${o.unit ?? "units"} × ₹${o.unitPrice}`
    );
    doc.text("HSN 0801 · fresh produce");
    doc.moveDown(0.5);
    doc.text(`Taxable value: ₹${taxable}`);
    doc.text("CGST (0% — exempt): ₹0");
    doc.text("SGST (0% — exempt): ₹0");
    doc.fontSize(13).text(`Grand total: ₹${taxable}`, {underline: true});
  });

  const url = await upload(`invoices/${orderId}.pdf`, buffer);
  await orderSnap.ref.update({invoiceUrl: url, invoicedAt: FieldValue.serverTimestamp()});
  return url;
}

export const generateInvoice = onCall(async (request) => {
  const orderId = request.data.orderId as string;
  if (!orderId) throw new HttpsError("invalid-argument", "orderId required.");
  const url = await buildInvoicePdf(orderId);
  return {invoiceUrl: url};
});
