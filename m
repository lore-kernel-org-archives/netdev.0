From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ks8842 depends on DMA_ENGINE
Date: Fri, 30 Jul 2010 22:10:12 -0700 (PDT)
Message-ID: <20100730.221012.112594570.davem@davemloft.net>
References: <20100729143211.9e7edaed.sfr@canb.auug.org.au>
	<20100729101427.2aafd6e7.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100729101427.2aafd6e7.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 29 Jul 2010 10:14:27 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> ks8842 uses dma channel functions, so it should depend on DMA_ENGINE.
> 
> ERROR: "__dma_request_channel" [drivers/net/ks8842.ko] undefined!
> ERROR: "dma_release_channel" [drivers/net/ks8842.ko] undefined!
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
