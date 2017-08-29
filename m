From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/4] sgiseeq: switch to dma_alloc_attrs
Date: Tue, 29 Aug 2017 10:02:43 +0200
Message-ID: <20170829080243.GA10358@lst.de>
References: <20170826072125.9790-1-hch@lst.de> <20170826072125.9790-2-hch@lst.de> <20170828.154151.502026172655565151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@vger.kernel.org, ralf@linux-mips.org,
        linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828.154151.502026172655565151.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2017 at 03:41:51PM -0700, David Miller wrote:
> From: Christoph Hellwig <hch@lst.de>
> Date: Sat, 26 Aug 2017 09:21:22 +0200
> 
> > Use dma_alloc_attrs directly instead of the dma_alloc_noncoherent wrapper.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Acked-by: David S. Miller <davem@davemloft.net>

I take the Acks as an ok to merges these patches through the dma-mapping
tree.  Thanks Dave!
