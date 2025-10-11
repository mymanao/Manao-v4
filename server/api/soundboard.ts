import { readdirSync } from "node:fs";
import { join } from "node:path";
import type { Elysia } from "elysia";

export function registerSoundboardAPI(app: Elysia) {
  app.get("/api/sounds", () => {
    const sounds = readdirSync(join(process.cwd(), "/server/public/sounds"));
    return sounds.map((sound) => `/sounds/${sound}`);
  });
}
