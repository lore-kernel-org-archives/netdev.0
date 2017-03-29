From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: mvneta: add RGMII_RXID and RGMII_TXID
 support
Date: Wed, 29 Mar 2017 14:57:06 +0200
Message-ID: <20170329125706.GC28922@lunn.ch>
References: <20170329084226.3472-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni@free-electrons.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329084226.3472-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 04:42:26PM +0800, Jisheng Zhang wrote:
> RGMII_RXID and RGMII_TX_ID share the same GMAC CTRL setting as RGMII
> or RGMII_ID.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Looks reasonable.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
