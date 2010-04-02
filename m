From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] fix problems with NETIF_F_HIGHDMA in networking
 drivers v2
Date: Thu, 01 Apr 2010 19:53:35 -0700 (PDT)
Message-ID: <20100401.195335.203662681.davem@davemloft.net>
References: <20100326123250A.fujita.tomonori@lab.ntt.co.jp>
	<20100325.203520.234306178.davem@davemloft.net>
	<20100331173507I.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hancockrwd@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	bzolnier@gmail.com
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753828Ab0DBCxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:53:34 -0400
In-Reply-To: <20100331173507I.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 31 Mar 2010 17:35:50 +0900

> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH] net: change illegal_highdma to use dma_mask

This is a good start, applied to net-next-2.6, thanks!
