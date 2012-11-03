From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/at91_ether: fix the use of macb structure
Date: Sat, 03 Nov 2012 15:04:14 -0400 (EDT)
Message-ID: <20121103.150414.707741347606909244.davem@davemloft.net>
References: <75eb5df193c504e68ebff7d6a6a88d9a1cc678cb.1351591858.git.nicolas.ferre@atmel.com>
	<1351596628-3405-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, havard@skinnemoen.net,
	bhutchings@solarflare.com, linux-arm-kernel@lists.infradead.org,
	plagnioj@jcrosoft.com, patrice.vilchez@atmel.com,
	linux-kernel@vger.kernel.org, manabian@gmail.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351596628-3405-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Tue, 30 Oct 2012 12:30:28 +0100

> Due to the use of common structure in at91_ether and macb drivers,
> change the name of DMA descriptor structures in at91_ether as well:
> dma_desc => macb_dma_desc
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

This does not apply to net-next, respin it if this change is
still relevant.
