From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Sun, 01 Dec 2013 20:25:18 -0500 (EST)
Message-ID: <20131201.202518.357889616067021901.davem@davemloft.net>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
	<9848F2DB572E5649BA045B288BE08FBE01899801@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bigeasy@linutronix.de, netdev@vger.kernel.org,
	Fabio.Estevam@freescale.com, frank.li@freescale.net,
	jim_baxter@mentor.com, m.szyprowski@samsung.com
To: fugang.duan@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab3LBBZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:25:20 -0500
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE01899801@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <fugang.duan@freescale.com>
Date: Wed, 27 Nov 2013 13:08:18 +0000

> I will do overnight stress test for the patch tomorrow.

So, what was the result of your testing?

Can you please Ack this patch if there are no problems with it and
your testing went well?

Thanks.
