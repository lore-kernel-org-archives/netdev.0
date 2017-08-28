From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] i825xx: switch to switch to dma_alloc_attrs
Date: Mon, 28 Aug 2017 15:42:21 -0700 (PDT)
Message-ID: <20170828.154221.1152120540177040528.davem@davemloft.net>
References: <20170826072125.9790-1-hch@lst.de>
        <20170826072125.9790-4-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
        linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: hch@lst.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170826072125.9790-4-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sat, 26 Aug 2017 09:21:24 +0200

> This way we can always pass DMA_ATTR_NON_CONSISTENT, the SNI mips version
> will simply ignore the flag.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: David S. Miller <davem@davemloft.net>
