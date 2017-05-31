From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/2] ARM: dts: imx6ul-14x14-evk: Add ksz8081 phy
 properties
Date: Wed, 31 May 2017 14:52:47 -0700
Message-ID: <a0dfb9a6-b958-c314-0610-127fdf175134@gmail.com>
References: <cover.1496224930.git.leonard.crestez@nxp.com>
 <1adf8f0d44afec4d11dec7f09d54d37d58cda5ff.1496224930.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andy Duan <fugang.duan@nxp.com>, Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Leonard Crestez <leonard.crestez@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Shawn Guo <shawnguo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1adf8f0d44afec4d11dec7f09d54d37d58cda5ff.1496224930.git.leonard.crestez@nxp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/31/2017 03:29 AM, Leonard Crestez wrote:
> Right now mach-imx6ul registers a fixup for the ksz8081 phy. The same
> register values can be set through the micrel phy driver by using dts
> properties.
> 
> This seems preferable and allows cleanly fixing suspend/resume.
> 
> Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>
> Reviewed-by: Fabio Estevam <fabio.estevam@nxp.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
