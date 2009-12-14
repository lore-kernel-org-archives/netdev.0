From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.32-git7] 3c574_cs: disable irq before
 calling el3_interrupt
Date: Sun, 13 Dec 2009 19:48:15 -0800 (PST)
Message-ID: <20091213.194815.48517182.davem@davemloft.net>
References: <20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091213094411.18be2ff6.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50716
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755946AbZLNDsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:48:14 -0500
In-Reply-To: <20091213094411.18be2ff6.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 13 Dec 2009 09:44:11 +0900

> 
> 3c574_cs, 3c589_cs:
> 	disable irq before calling el3_interrupt
> 	in the media_check function.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thanks.
