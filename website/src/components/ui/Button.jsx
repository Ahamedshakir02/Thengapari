/**
 * Thin wrapper over the design's `.btn` classes. Renders an <a> by default,
 * or a <button> when `onClick`/`type` is supplied without an href.
 * `variant`: 'accent' | 'outline' | 'brand' | 'ghost'.
 */
export default function Button({ variant = 'accent', size, href, className = '', children, ...rest }) {
  const cls = `btn btn-${variant}${size === 'lg' ? ' btn-lg' : ''}${className ? ` ${className}` : ''}`;
  if (href) {
    return (
      <a href={href} className={cls} {...rest}>
        {children}
      </a>
    );
  }
  return (
    <button type="button" className={cls} {...rest}>
      {children}
    </button>
  );
}
