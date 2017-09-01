From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/4] net: mvpp2: take advantage of the
 is_rgmii helper
Date: Fri, 1 Sep 2017 15:33:53 +0200
Message-ID: <20170901133353.GW22289@lunn.ch>
References: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
 <20170901090455.32316-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170901090455.32316-2-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2017 at 11:04:52AM +0200, Antoine Tenart wrote:
> Convert all RGMII checks to use the phy_interface_mode_is_rgmii()
> helper. This is a cosmetic patch.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
