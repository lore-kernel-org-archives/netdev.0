From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: make mvneta_eth_tool_ops static
Date: Fri, 17 Feb 2017 12:16:55 -0500 (EST)
Message-ID: <20170217.121655.936945959003335816.davem@davemloft.net>
References: <20170216090739.2632-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: jszhang@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216090739.2632-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jisheng Zhang <jszhang@marvell.com>
Date: Thu, 16 Feb 2017 17:07:39 +0800

> The mvneta_eth_tool_ops is only used internally in mvneta driver, so
> make it static.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Applied to net-next, thanks.
