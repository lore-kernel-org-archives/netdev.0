From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next] net: mvneta: implement .set_wol and
 .get_wol
Date: Mon, 06 Feb 2017 10:54:24 -0500 (EST)
Message-ID: <20170206.105424.658086420075790490.davem@davemloft.net>
References: <20170206065813.1971-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        houjingj@marvell.com
To: jszhang@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206065813.1971-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jisheng Zhang <jszhang@marvell.com>
Date: Mon, 6 Feb 2017 14:58:13 +0800

> From: Jingju Hou <houjingj@marvell.com>
> 
> The mvneta itself does not support WOL, but the PHY might.
> So pass the calls to the PHY
> 
> Signed-off-by: Jingju Hou <houjingj@marvell.com>
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Applied.
