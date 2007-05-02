From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 11:29:06 -0400
Message-ID: <4638AE42.5000908@garzik.org>
References: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59308 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993363AbXEBP3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 11:29:11 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> A non-IOMMU system using 64-bit dma_addr_t will always set
> CONFIG_HIGHMEM, right?

No.

	Jeff



