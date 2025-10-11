import { logger } from "@helpers/logger";
import { setupAuthProvider } from "@twitch/services/auth";
import { initializeChatClient } from "@twitch/services/chat";
import { initializeEventSub } from "@twitch/services/eventsub";

const authProvider = setupAuthProvider();
export const { chatClient, apiClient } =
  await initializeChatClient(authProvider);

await initializeEventSub(chatClient, apiClient);

logger.info("[Manao] Bot successfully initialized");
