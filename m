From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH net-next 0/2] ravb: Support 1Gbps on R-Car H3 ES1.1+ and
 R-Car M3-W
Date: Fri, 27 Jan 2017 13:16:43 +0100
Message-ID: <CAMuHMdUdHVcFpQyqtngps__Z99vWBYbs1vVvVSLvKBWSEkOrgw@mail.gmail.com>
References: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Magnus Damm <magnus.damm@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon,

On Fri, Jan 27, 2017 at 12:04 PM, Simon Horman
<horms+renesas@verge.net.au> wrote:
> The path from Mizuguchi-san is to address timing problems observed with
> gigabit transfers. I would like it considered although my own testing on
> M3-W did not show any timing problems.

Is there any relation with the *-skew-ps properties in the DTS in the BSP?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
