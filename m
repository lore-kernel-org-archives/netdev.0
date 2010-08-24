From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif-driver: add HAS_DMA dependency
Date: Tue, 24 Aug 2010 12:21:21 -0700 (PDT)
Message-ID: <20100824.122121.104040542.davem@davemloft.net>
References: <20100824151427.GC2160@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, schwidefsky@de.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: heiko.carstens@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100824151427.GC2160@osiris.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Tue, 24 Aug 2010 17:14:27 +0200

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Fix this error on an s390 allyesconfig build:
> 
> linux-2.6/drivers/net/caif/caif_spi.c:98:
>     undefined reference to `dma_free_coherent'
> 
> Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Applied, thanks.
