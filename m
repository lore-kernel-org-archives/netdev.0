From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH/RFC net-next] ravb: use clock rate as basis for GTI.TIV
Date: Mon, 2 Nov 2015 08:51:41 +0100
Message-ID: <CAMuHMdVQWMc-giQb-J0JV9JXLCYLXHQJhStRgwHZX0qjgye0cw@mail.gmail.com>
References: <1446428439-10944-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1446428439-10944-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 2, 2015 at 2:40 AM, Simon Horman <horms+renesas@verge.net.au> wrote:
> The motivation for this is to use the correct rate on
> the r8a7795/Slavator-X which is advertised as 133MHz but

Salvator-X

> may differ depending on the extal present on the Slavator-X.

Salvator-X

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
