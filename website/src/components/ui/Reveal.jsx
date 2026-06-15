import { useReveal } from '../../lib/useReveal';

/**
 * Wraps content with a subtle reveal-on-scroll. `delayStep` (0,1,2,…) staggers
 * siblings; matches the design's `data-d` cadence (~90ms apart).
 */
export default function Reveal({ as: Tag = 'div', delayStep = 0, className = '', children, ...rest }) {
  const [ref, shown] = useReveal();
  return (
    <Tag
      ref={ref}
      className={`reveal${shown ? ' in' : ''}${className ? ` ${className}` : ''}`}
      style={{ transitionDelay: shown ? `${delayStep * 90}ms` : '0ms' }}
      {...rest}
    >
      {children}
    </Tag>
  );
}
