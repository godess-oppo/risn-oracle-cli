export function hashString(input: string): string {
  let h = 0, i = 0, len = input.length;
  while (i < len) h = (h << 5) - h + input.charCodeAt(i++) | 0;
  return (h >>> 0).toString(16);
}
