From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2] net: sh_eth: fix driver dependencies
Date: Mon, 1 Sep 2014 18:36:19 +0200
Message-ID: <CAMuHMdWGdD+-o9Z8gPYwJWJmjhBqfw0HA4ve=RH+adLFJEZa8Q@mail.gmail.com>
References: <1749721.1a6rN6K2Gg@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1749721.1a6rN6K2Gg@amdc1032>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 1, 2014 at 4:25 PM, Bartlomiej Zolnierkiewicz
<b.zolnierkie@samsung.com> wrote:
> Renesas SuperH Ethernet support should be available only on
> Renesas ARM SoCs and SuperH architecture.
>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Magnus Damm <magnus.damm@gmail.com>
> ---
> v2:
> - s/ARCH_SH/SUPERH/ (thanks to Sergei Shtylyov)

Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
