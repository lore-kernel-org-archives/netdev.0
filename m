From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] SubmittingPatches: clarify SOB tag usage when evolving submissions
Date: Thu, 9 Aug 2012 22:58:27 +0200
Message-ID: <CAMuHMdUd5x04KyyKa84J3PDB2xPj70xZLezwMJn1J=jwmzcnnA@mail.gmail.com>
References: <1344545493-6820-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: torvalds@linux-foundation.org, rdunlap@xenotime.net, tytso@mit.edu,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344545493-6820-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 9, 2012 at 10:51 PM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> of a second patch submission must supply their own Siged-off-by

Signed-off-by

> --- a/Documentation/SubmittingPatches
> +++ b/Documentation/SubmittingPatches
> @@ -366,6 +366,21 @@ and protect the submitter from complaints. Note that under no circumstances
>  can you change the author's identity (the From header), as it is the one
>  which appears in the changelog.
>
> +If you are submitting a large change (for example a new driver) at times
> +you may be asked to make quite a lot of modifications prior to getting
> +your change accepted. At times you may even receive patches from developers
> +who not only wish to tell you what you should change to get your changes
> +upstream but actually send you patches. If those patches were made publicly
> +and they do contain a Singed-off-by tag you are not expected to provide

Signed-off-by

> +their own Singed-off-by tag on the second iteration of the patch so long

idem

> +as there is a public record somewhere that can be used to show the
> +contributor had sent their changes with their own Singed-off-by tag.

ditto

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
