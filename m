From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.33-rc2] axnet_cs: remove unnecessary
 spin_unlock_irqrestore
Date: Sun, 03 Jan 2010 21:52:53 -0800 (PST)
Message-ID: <20100103.215253.29943199.davem@davemloft.net>
References: <20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20091229101724.7a077507.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48509
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752306Ab0ADFwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:52:49 -0500
In-Reply-To: <20091229101724.7a077507.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Tue, 29 Dec 2009 10:17:24 +0900

> 
> axnet_cs:
>     remove unnecessary spin_unlock_irqrestore,spin_lock_irqsave.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied to net-next-2.6
