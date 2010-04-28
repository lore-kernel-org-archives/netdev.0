From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: use the DMA state API instead of the pci
 equivalents
Date: Wed, 28 Apr 2010 09:08:16 -0700
Message-ID: <20100428090816.39436663@nehalam>
References: <20100428095826S.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42845 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755445Ab0D1QJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 12:09:08 -0400
In-Reply-To: <20100428095826S.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Apr 2010 09:57:05 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

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

Tested, this works thanks.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>


-- 
