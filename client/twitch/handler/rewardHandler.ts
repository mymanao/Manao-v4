import { getSoundFromRewardId } from "@helpers/preferences.ts";
import { io } from "@/server";

export async function handleReward(data: any) {
  const { rewardId: id, rewardTitle: name } = data;
  const sound = getSoundFromRewardId(id);
  if (sound) {
    io.emit("play-sound", { url: sound, name });
  }
}
