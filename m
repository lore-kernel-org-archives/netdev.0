From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/2] ARM: dts: imx6ul-14x14-evk: Add ksz8081 phy properties
Date: Wed, 31 May 2017 01:08:23 -0300
Message-ID: <CAOMZO5A8BaehXMcJ38k24OMV7P-edXZsS8JZ5wefOcyCu1jOOQ@mail.gmail.com>
References: <cover.1496164448.git.leonard.crestez@nxp.com> <d31aab90fbdecaf4c5f240becb2d0b0efb23f5c3.1496164448.git.leonard.crestez@nxp.com>
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
In-Reply-To: <d31aab90fbdecaf4c5f240becb2d0b0efb23f5c3.1496164448.git.leonard.crestez@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 2:34 PM, Leonard Crestez
<leonard.crestez@nxp.com> wrote:
> Right now mach-imx6ul registers a fixup for the ksz8081 phy. The same
> register values can be set through the micrel phy driver by using dts
> properties.
>
> This seems preferable and allows cleanly fixing suspend/resume.
>
> Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>

Reviewed-by: Fabio Estevam <fabio.estevam@nxp.com>
