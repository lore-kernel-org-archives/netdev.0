From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4vf: remove obsolete DECLARE_PCI_UNMAP_ADDR usage
Date: Thu, 08 Jul 2010 23:08:34 -0700 (PDT)
Message-ID: <20100708.230834.246518215.davem@davemloft.net>
References: <20100708185111D.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752465Ab0GIGIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:08:19 -0400
In-Reply-To: <20100708185111D.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 8 Jul 2010 18:52:37 +0900

> We could use DEFINE_DMA_UNMAP_ADDR instead but using
> CONFIG_NEED_DMA_MAP_STATE is a simpler way to see if a platform does
> real DMA unmapping.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Applied.
