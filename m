From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH/RFC] dma-mapping: Provide dummy set_dma_ops() for
        NO_DMA=y
Date: Mon, 10 Jul 2017 16:56:41 +0200
Message-ID: <20170710145641.GC7971@lst.de>
References: <1499628825-16260-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1499628825-16260-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This looks reasonable to me, I'd be happy to pick it up.  Can you send
it as a series with the reverts?
