// app-icons.jsx — single <Icon name size color strokeWidth/> component.
// UI icons are 24-grid stroke icons; crop glyphs are small filled motifs.

function Icon({ name, size = 24, color = 'currentColor', sw = 2, style }) {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
    stroke: color, strokeWidth: sw, strokeLinecap: 'round', strokeLinejoin: 'round',
    style, 'aria-hidden': true };
  switch (name) {
    // ---- nav / ui (stroke) ----
    case 'home': return (<svg {...p}><path d="M4 11.5 12 4l8 7.5"/><path d="M6 10.5V20h12v-9.5"/><path d="M10 20v-5h4v5"/></svg>);
    case 'calendar': return (<svg {...p}><rect x="4" y="5" width="16" height="16" rx="3"/><path d="M4 9h16M8 3v4M16 3v4"/><circle cx="9" cy="14" r=".6" fill={color}/><circle cx="13" cy="14" r=".6" fill={color}/><circle cx="9" cy="17.5" r=".6" fill={color}/></svg>);
    case 'report': return (<svg {...p}><rect x="5" y="3" width="14" height="18" rx="3"/><path d="M9 12v4M12 9v7M15 13v3"/></svg>);
    case 'profile': return (<svg {...p}><circle cx="12" cy="8.5" r="3.6"/><path d="M5.5 19.5a6.5 6.5 0 0 1 13 0"/></svg>);
    case 'bell': return (<svg {...p}><path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Z"/><path d="M10 19a2 2 0 0 0 4 0"/></svg>);
    case 'chevron-left': return (<svg {...p}><path d="M15 5l-7 7 7 7"/></svg>);
    case 'chevron-right': return (<svg {...p}><path d="M9 5l7 7-7 7"/></svg>);
    case 'arrow-right': return (<svg {...p}><path d="M4 12h15M13 6l6 6-6 6"/></svg>);
    case 'plus': return (<svg {...p}><path d="M12 5v14M5 12h14"/></svg>);
    case 'check': return (<svg {...p}><path d="M5 12.5 10 17l9-10"/></svg>);
    case 'check-bold': return (<svg {...p} strokeWidth="2.6"><path d="M5 12.5 10 17l9-10"/></svg>);
    case 'star': return (<svg {...p}><path d="M12 4l2.4 4.9 5.4.8-3.9 3.8.9 5.4-4.8-2.5-4.8 2.5.9-5.4L4.2 9.7l5.4-.8Z"/></svg>);

    // ---- meaningful (stroke) ----
    case 'rupee': return (<svg {...p}><path d="M7 5h10M7 9h10M16 5c0 4-3.5 5-7 5l7 9"/></svg>);
    case 'feather': return (<svg {...p}><path d="M19 5c-3 0-9 1-12 8l-3 5"/><path d="M19 5c0 6-4 11-10 11H4"/><path d="M9 13h6"/></svg>);
    case 'pin': return (<svg {...p}><path d="M12 21s7-6.3 7-11a7 7 0 1 0-14 0c0 4.7 7 11 7 11Z"/><circle cx="12" cy="10" r="2.6"/></svg>);
    case 'clock': return (<svg {...p}><circle cx="12" cy="12" r="8"/><path d="M12 7.5V12l3 2"/></svg>);
    case 'camera': return (<svg {...p}><path d="M4 8.5A1.5 1.5 0 0 1 5.5 7h2L9 5h6l1.5 2h2A1.5 1.5 0 0 1 20 8.5v9A1.5 1.5 0 0 1 18.5 19h-13A1.5 1.5 0 0 1 4 17.5Z"/><circle cx="12" cy="12.5" r="3.2"/></svg>);
    case 'scale': return (<svg {...p}><path d="M12 4v16M7 4h10"/><path d="M7 4 4 11a3 3 0 0 0 6 0L7 4Z"/><path d="M17 4l-3 7a3 3 0 0 0 6 0l-3-7Z"/></svg>);
    case 'droplet': return (<svg {...p}><path d="M12 3.5c3 4 5.5 6.6 5.5 9.5a5.5 5.5 0 0 1-11 0c0-2.9 2.5-5.5 5.5-9.5Z"/></svg>);
    case 'trend-up': return (<svg {...p}><path d="M4 16l5-5 3 3 7-7"/><path d="M16 7h4v4"/></svg>);
    case 'recycle': return (<svg {...p}><path d="M8 5.5 10.3 9 6.5 9.2l-2.3 4a2 2 0 0 0 1.7 3H8"/><path d="M14.5 6.5 13 4h-2.5"/><path d="M16.5 9.5 18.8 13l2-.6"/><path d="M14 18.5h3.8a2 2 0 0 0 1.7-3l-1-1.7"/><path d="M11 18.5 14 21l.2-3.6"/></svg>);
    case 'phone': return (<svg {...p}><path d="M6.5 4h3l1.5 4-2 1.5a11 11 0 0 0 5 5l1.5-2 4 1.5v3a2 2 0 0 1-2 2A15 15 0 0 1 4.5 6a2 2 0 0 1 2-2Z"/></svg>);
    case 'chat': return (<svg {...p}><path d="M5 5h14a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H9l-4 3.5V6a1 1 0 0 1 1-1Z"/></svg>);
    case 'leaf': return (<svg {...p}><path d="M5 19c0-8 6-13 14-13 0 8-5 14-13 14"/><path d="M5 19c2-4 5-7 9-9"/></svg>);
    case 'tree': return (<svg {...p}><path d="M12 21v-5"/><path d="M12 16c-3.5 0-6-2.4-6-5.5C6 7 8.5 4 12 4s6 3 6 6.5c0 3.1-2.5 5.5-6 5.5Z"/></svg>);
    case 'wallet': return (<svg {...p}><rect x="4" y="6" width="16" height="13" rx="3"/><path d="M4 9h16"/><circle cx="16" cy="14" r="1.4" fill={color} stroke="none"/></svg>);
    case 'shield': return (<svg {...p}><path d="M12 3l7 2.5V11c0 5-3.5 8-7 10-3.5-2-7-5-7-10V5.5Z"/><path d="M9 12l2 2 4-4"/></svg>);
    case 'globe': return (<svg {...p}><circle cx="12" cy="12" r="8"/><path d="M4 12h16M12 4c2.5 2.5 2.5 13 0 16M12 4c-2.5 2.5-2.5 13 0 16"/></svg>);
    case 'help': return (<svg {...p}><circle cx="12" cy="12" r="8"/><path d="M9.5 9.5a2.5 2.5 0 0 1 4.8 1c0 1.7-2.3 2-2.3 3.5"/><circle cx="12" cy="17" r=".7" fill={color} stroke="none"/></svg>);
    case 'whatsapp': return (<svg width={size} height={size} viewBox="0 0 24 24" fill={color} aria-hidden="true" style={style}><path d="M12 2a10 10 0 0 0-8.6 15l-1.3 4.8 4.9-1.3A10 10 0 1 0 12 2Zm5.6 14.2c-.2.6-1.4 1.2-1.9 1.2-.5.1-1.1.1-1.8-.1-.4-.1-1-.3-1.7-.6-3-1.3-4.9-4.3-5-4.5-.2-.2-1.2-1.6-1.2-3 0-1.5.7-2.2 1-2.5.2-.3.5-.4.7-.4h.5c.2 0 .4 0 .6.5l.8 1.9c.1.2.1.3 0 .5l-.4.6-.3.3c-.2.2-.3.4-.2.7.2.3.8 1.3 1.7 2.1 1.2 1 2.1 1.4 2.4 1.5.2.1.4.1.6-.1l.7-.9c.2-.2.4-.2.6-.1l1.9.9c.2.1.4.2.4.3.1.2.1.8-.1 1.4Z"/></svg>);

    // ---- crop glyphs (filled) ----
    case 'coconut': return (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={style} aria-hidden="true"><path d="M12 9c0-3-1-5.4-3.6-7 -.3 3 .9 5.2 3.6 6.6Z" fill={color}/><path d="M12 9c0-3 1-5.4 3.6-7 .3 3-.9 5.2-3.6 6.6Z" fill={color} opacity=".7"/><circle cx="12" cy="15.5" r="5.6" fill={color}/><circle cx="10" cy="14.5" r=".95" fill="#fff" opacity=".55"/><circle cx="14" cy="14.5" r=".95" fill="#fff" opacity=".55"/><circle cx="12" cy="17.6" r=".95" fill="#fff" opacity=".55"/></svg>);
    case 'mango': return (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={style} aria-hidden="true"><path d="M16.5 6c2.5 2 3 5.5 1.2 8.4-1.7 2.8-5.2 4.2-8.4 3.3-2.6-.8-3.8-3-3-5.6C7.4 8 12 5 16.5 6Z" fill={color}/><path d="M16.5 6c.7-1 1.7-1.6 2.8-1.7-.2 1.2-.9 2.1-1.9 2.6" stroke={color} strokeWidth="1.6" strokeLinecap="round"/></svg>);
    case 'pepper': return (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={style} aria-hidden="true"><path d="M12 4c2 0 3 1.2 3 2.5" stroke={color} strokeWidth="1.6" strokeLinecap="round"/><g fill={color}><circle cx="11" cy="9" r="1.5"/><circle cx="14" cy="10.5" r="1.5"/><circle cx="10.5" cy="12.5" r="1.5"/><circle cx="13.5" cy="14" r="1.5"/><circle cx="11.5" cy="16" r="1.5"/><circle cx="14.5" cy="17.5" r="1.5"/><circle cx="12" cy="19" r="1.5"/></g></svg>);
    case 'banana': return (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={style} aria-hidden="true"><path d="M6 5c.5 5 4 9 10 9.5 1.2.1 2-.4 2-1.3 0-.6-.5-1-1.4-1.1C11 11.5 8 8.5 7.6 4.8 7.5 4 6 4 6 5Z" fill={color}/></svg>);
    case 'areca': return (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={style} aria-hidden="true"><ellipse cx="12" cy="13" rx="5" ry="6.5" fill={color}/><path d="M12 6.5c0-1.6.8-2.8 2.4-3.3.2 1.6-.6 2.8-2 3.3Z" fill={color} opacity=".7"/></svg>);
    case 'jackfruit': return (<svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={style} aria-hidden="true"><path d="M12 4c.2-1 1-1.4 2-1.2-.2 1-.8 1.5-1.6 1.5" stroke={color} strokeWidth="1.5" strokeLinecap="round"/><ellipse cx="12" cy="13.5" rx="6" ry="7" fill={color}/><g fill="#fff" opacity=".4"><circle cx="10" cy="11" r="1"/><circle cx="14" cy="11" r="1"/><circle cx="12" cy="13.5" r="1"/><circle cx="10" cy="16" r="1"/><circle cx="14" cy="16" r="1"/></g></svg>);

    default: return null;
  }
}

Object.assign(window, { Icon });
