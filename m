From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 1/4] net: dsa: add support for the SMSC-LAN9303
 tagging format
Date: Wed, 12 Apr 2017 16:45:21 +0200
Message-ID: <20170412144521.GB7023@lunn.ch>
References: <20170412140218.1076-1-jbe@pengutronix.de>
 <20170412140218.1076-2-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170412140218.1076-2-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 04:02:15PM +0200, Juergen Borleis wrote:
> To define the outgoing port and to discover the incoming port a regular
> VLAN tag is used by the LAN9303. But its VID meaning is 'special'.
> 
> This tag handler/filter depends on some hardware features which must be
> enabled in the device to provide and make use of this special VLAN tag
> to control the destination and the source of an ethernet packet.
> 
> Signed-off-by: Juergen Borleis <jbe@pengutronix.de>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
