import { Category } from "@discordx/utilities";
import { templateEmbed } from "@helpers/embed.ts";
import type { CommandInteraction } from "discord.js";
import { Discord, Slash } from "discordx";

@Discord()
@Category("Info")
export class PingCommand {
  @Slash({
    description: "Check the bot's responsiveness",
  })
  async ping(interaction: CommandInteraction): Promise<void> {
    await interaction.reply({
      embeds: [
        templateEmbed({
          type: "success",
          title: "Pong!",
          description: `Latency is ${Date.now() - interaction.createdTimestamp}ms.`,
          interaction: interaction,
        }),
      ],
    });
  }
}
