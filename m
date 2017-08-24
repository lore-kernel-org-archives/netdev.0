From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 01/13] phy: add sgmii and 10gkr modes to the
 phy_mode enum
Date: Thu, 24 Aug 2017 15:19:38 +0200
Message-ID: <20170824131938.GB8022@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824083823.16826-2-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 10:38:11AM +0200, Antoine Tenart wrote:
> This patch adds more PHY modes to the phy_mode enum, to allow
> configuring PHYs to the SGMII and/or the 10GKR mode by using the
> set_mode callback.

Hi Antoine

You had me confused for a while here. If there is need for a respin,
could you change the commit log and prefix PHY with either generic or
Ethernet, just to make it clear which PHY subsystem we are talking
about.

	Andrew
