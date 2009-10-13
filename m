From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.32-rc3] 3c574_cs: spin_lock the
 set_multicast_list function
Date: Tue, 13 Oct 2009 00:33:07 -0700 (PDT)
Message-ID: <20091013.003307.233949122.davem@davemloft.net>
References: <20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091011211225.35e6fb4a.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57700
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756022AbZJMHdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:33:11 -0400
In-Reply-To: <20091011211225.35e6fb4a.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 11 Oct 2009 21:12:25 +0900

> 3c574_cs:
>  spin_lock the set_multicast_list function.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thanks!

