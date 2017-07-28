From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/4] net: dsa: lan9303: Multiply by 4 to get
 MDIO register
Date: Fri, 28 Jul 2017 17:20:37 +0200
Message-ID: <20170728152037.GF2132@lunn.ch>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170728151157.28983-3-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 05:11:55PM +0200, Egil Hjelmeland wrote:
> lan9303_mdio_write()/_read() must multiply register number by 4 to get
> offset.
> 
> Added some commments to the register definitions.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
