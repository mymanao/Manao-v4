import "@/client/twitch";
import { run } from "@/client/discord";
import { startServer } from "./server";
import { Server } from "socket.io";

startServer();

await run();
