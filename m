From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] starfire: clean up dma_addr_t size test
Date: Fri, 01 Apr 2011 20:10:28 -0700 (PDT)
Message-ID: <20110401.201028.115931352.davem@davemloft.net>
References: <20110402002600P.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752217Ab1DBDLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:11:05 -0400
In-Reply-To: <20110402002600P.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Sat, 2 Apr 2011 00:27:51 +0900

> Now we have CONFIG_ARCH_DMA_ADDR_T_64BIT. We can fix the hacky
> dma_addr_t size test cleanly.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Applied, thank you for remembering to do this!
