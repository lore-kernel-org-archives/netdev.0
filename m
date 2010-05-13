From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: use the DMA state API instead of the pci
 equivalents
Date: Wed, 12 May 2010 23:43:15 -0700 (PDT)
Message-ID: <20100512.234315.15222331.davem@davemloft.net>
References: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36365
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753220Ab0EMGnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:43:07 -0400
In-Reply-To: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 28 Apr 2010 09:57:04 +0900

> This replace the PCI DMA state API (include/linux/pci-dma.h) with the
> DMA equivalents since the PCI DMA state API will be obsolete.
> 
> No functional change.
> 
> For further information about the background:
> 
> http://marc.info/?l=linux-netdev&m=127037540020276&w=2
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Stephen, ping?  How did the testing go?
