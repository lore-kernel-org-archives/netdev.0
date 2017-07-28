From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/4] net: dsa: lan9303: Fix
 lan9303_detect_phy_setup() for MDIO
Date: Fri, 28 Jul 2017 17:19:34 +0200
Message-ID: <20170728151934.GE2132@lunn.ch>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170728151157.28983-2-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 05:11:54PM +0200, Egil Hjelmeland wrote:
> Handle that MDIO read with no response return 0xffff.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
