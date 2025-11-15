export type RISNPlugin = {
  name: string;
  version: string;
  init: () => Promise<void> | void;
  hooks: Record<string, Function>;
};
