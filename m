From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 net-next] net: mvneta: implement .set_wol and .get_wol
Date: Mon, 6 Feb 2017 14:05:26 +0100
Message-ID: <20170206130526.GC32506@lunn.ch>
References: <20170206065813.1971-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni@free-electrons.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jingju Hou <houjingj@marvell.com>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170206065813.1971-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 06, 2017 at 02:58:13PM +0800, Jisheng Zhang wrote:
> From: Jingju Hou <houjingj@marvell.com>
> 
> The mvneta itself does not support WOL, but the PHY might.
> So pass the calls to the PHY
> 
> Signed-off-by: Jingju Hou <houjingj@marvell.com>
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
