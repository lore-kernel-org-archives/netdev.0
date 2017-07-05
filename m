From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v 2/2] ARM: shmobile: defconfig: Enable Ethernet AVB
Date: Wed, 5 Jul 2017 15:45:43 +0200
Message-ID: <CAMuHMdUAWXzdsp0NujnhKpajmv11aGZNeAA0PURUA1fP9NCrAw@mail.gmail.com>
References: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com> <1499259711-56175-3-git-send-email-biju.das@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Chris Paterson <chris.paterson2@renesas.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Biju Das <biju.das@bp.renesas.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1499259711-56175-3-git-send-email-biju.das@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 5, 2017 at 3:01 PM, Biju Das <biju.das@bp.renesas.com> wrote:
> The iWave RZ/G1M Q7 SOM supports Gigabit Ethernet Phy (Micrel KSZ9031MNX).
> Gigabit Ethernet support is available in Renesas AVB driver.
> To increase hardware support enable the driver in the shmobile_defconfig
> multiplatform configuration.
>
> Signed-off-by: Biju Das <biju.das@bp.renesas.com>
> Reviewed-by: Chris Paterson <chris.paterson2@renesas.com>

Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
