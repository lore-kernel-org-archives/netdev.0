From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 19/44] s390: implement ->mapping_error
Date: Thu, 8 Jun 2017 18:23:11 +0200
Message-ID: <20170608182311.05cced9e@thinkpad>
References: <20170608132609.32662-1-hch@lst.de>
        <20170608132609.32662-20-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20170608132609.32662-20-hch@lst.de>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu,  8 Jun 2017 15:25:44 +0200
Christoph Hellwig <hch@lst.de> wrote:

> s390 can also use noop_dma_ops, and while that currently does not return
> errors it will so in the future.  Implementing the mapping_error method
> is the proper way to have per-ops error conditions.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

