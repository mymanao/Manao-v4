import { Category } from "@discordx/utilities";
import { templateEmbed } from "@helpers/embed.ts";
import type { CommandInteraction } from "discord.js";
import { Discord, Slash } from "discordx";

export const pendingLinks = new Map<
  string,
  { code: string; createdAt: number }
>();

@Discord()
@Category("Account")
export class LinkCommand {
  @Slash({ name: "link", description: "Link your Twitch account" })
  async link(interaction: CommandInteraction): Promise<void> {
    const discordID = interaction.user.id;
    const code = Math.random().toString(36).substring(2, 8).toUpperCase();

    pendingLinks.set(discordID, { code, createdAt: Date.now() });

    await interaction.reply({
      embeds: [
        templateEmbed({
          type: "default",
          title: "Link Your Twitch Account",
          fields: [
            {
              name: "Code",
              value: code,
              inline: true,
            },
          ],
          description: "Run !link <code> in Twitch chat to link your account.",
          interaction: interaction,
        }),
      ],
    });
  }
}
