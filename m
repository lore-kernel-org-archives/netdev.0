From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 0/8] 8390: Neatening
Date: Thu, 23 Jun 2011 20:04:13 +0200
Message-ID: <BANLkTinBoGpGEFmfDQ-JXAjFn-aRBSVEUw@mail.gmail.com>
References: <cover.1308810463.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60270 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933497Ab1FWSEO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 14:04:14 -0400
In-Reply-To: <cover.1308810463.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2011 at 08:38, Joe Perches <joe@perches.com> wrote:
> Some updates requested by Geert Uytterhoeven
>
> Joe Perches (8):
> =C2=A0ariadne: Update style, neaten, restructure to eliminate prototy=
pes
> =C2=A0a2065: Use pr_fmt, pr_<level> and netdev_<level>
> =C2=A0lib8390: Use pr_<level> and netdev_<level>
> =C2=A0lib8390: Indent braces appropriately
> =C2=A0lib8390: Normalize source code spacing
> =C2=A0lib8390: Convert include <asm to include <linux
> =C2=A0lib8390: Remove unnecessary extern
> =C2=A0zorro8390: Restructure and eliminate prototypes

Looks good. I had to make some minor adjustments to make it apply to my
current tree, though.

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Thanks!

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
