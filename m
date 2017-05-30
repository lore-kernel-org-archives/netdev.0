From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 2/2] net: phy: micrel: Restore led_mode and clk_sel on resume
Date: Tue, 30 May 2017 15:12:04 -0300
Message-ID: <CAOMZO5BzWQjxp656-x3zcj=VSOT2CfjJBVLNiPJaayCSejuUdA@mail.gmail.com>
References: <cover.1496164448.git.leonard.crestez@nxp.com> <a8d0393c977b0d6fdab5d48ad13ca4d1ca893a07.1496164448.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Shawn Guo <shawnguo@kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Andy Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Johan Hovold <johan@kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Leonard Crestez <leonard.crestez@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a8d0393c977b0d6fdab5d48ad13ca4d1ca893a07.1496164448.git.leonard.crestez@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Leonard,

On Tue, May 30, 2017 at 2:34 PM, Leonard Crestez
<leonard.crestez@nxp.com> wrote:
> These bits seem to be lost after a suspend/resume cycle so just set them
> again.
>
> This patch fixes ethernet suspend/resume on imx6ul-14x14-evk boards.
>
> Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>

When you send a v2 addressing Florian's comment, please make sure you
send it to David Miller (netdev maintainer).
