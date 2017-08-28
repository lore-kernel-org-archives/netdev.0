From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] sgiseeq: switch to dma_alloc_attrs
Date: Mon, 28 Aug 2017 15:41:51 -0700 (PDT)
Message-ID: <20170828.154151.502026172655565151.davem@davemloft.net>
References: <20170826072125.9790-1-hch@lst.de>
        <20170826072125.9790-2-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
        linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: hch@lst.de
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20170826072125.9790-2-hch@lst.de>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sat, 26 Aug 2017 09:21:22 +0200

> Use dma_alloc_attrs directly instead of the dma_alloc_noncoherent wrapper.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: David S. Miller <davem@davemloft.net>
