From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Fix 32-bit DMA Mask handling
Date: Thu, 13 Jun 2013 01:28:55 -0700 (PDT)
Message-ID: <20130613.012855.1387013202076891229.davem@davemloft.net>
References: <e97260be-0d58-4285-a8e5-c9b030d60132@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932663Ab3FMI24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 04:28:56 -0400
In-Reply-To: <e97260be-0d58-4285-a8e5-c9b030d60132@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Tue, 11 Jun 2013 17:18:22 +0530

> Fix to set the coherent DMA mask only if dma_set_mask() succeeded, and to
> error out if either fails.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
