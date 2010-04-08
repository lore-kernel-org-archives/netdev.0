From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: use the dma state API instead of the pci
 equivalents
Date: Wed, 07 Apr 2010 21:05:54 -0700 (PDT)
Message-ID: <20100407.210554.239736159.davem@davemloft.net>
References: <20100402115025A.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43727
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750758Ab0DHEFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:05:52 -0400
In-Reply-To: <20100402115025A.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 2 Apr 2010 11:56:57 +0900

> The DMA API is preferred.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Applied.
