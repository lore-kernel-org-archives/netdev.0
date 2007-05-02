From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 2 May 2007 16:28:01 +0100
Message-ID: <20070502152801.GB28987@infradead.org>
References: <20070502.001243.70193466.davem@davemloft.net> <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35739 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993364AbXEBP2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 11:28:07 -0400
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2007 at 08:23:40AM -0700, Michael Chan wrote:
> A non-IOMMU system using 64-bit dma_addr_t will always set
> CONFIG_HIGHMEM, right?

No. 

