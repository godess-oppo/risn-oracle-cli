export function validate(schema: any) {
  return (req: any, res: any, next: any) => {
    // tiny validator stub – replace with AJV/Zod if needed
    next();
  };
}
