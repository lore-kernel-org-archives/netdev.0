From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: lan9303: MDIO access phy
 registers directly
Date: Fri, 28 Jul 2017 17:24:03 +0200
Message-ID: <20170728152403.GH2132@lunn.ch>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-5-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170728151157.28983-5-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 05:11:57PM +0200, Egil Hjelmeland wrote:
> Indirect access (PMI) to phy register only work in I2C mode. In
> MDIO mode phy registers must be accessed directly. Introduced
> struct lan9303_phy_ops to handle the two modes.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
