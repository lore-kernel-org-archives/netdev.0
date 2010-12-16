From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.37-rc5] axnet_cs: move id (0x1bf, 0x2328) to
 axnet_cs
Date: Thu, 16 Dec 2010 12:39:22 -0800 (PST)
Message-ID: <20101216.123922.179927984.davem@davemloft.net>
References: <20101107001124.7d8ef6c4.ken_kawasaki@spring.nifty.jp>
	<20101114084208.b3ee991d.ken_kawasaki@spring.nifty.jp>
	<20101213212724.353e84f1.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752284Ab0LPUix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 15:38:53 -0500
In-Reply-To: <20101213212724.353e84f1.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Mon, 13 Dec 2010 21:27:24 +0900

> 
> axnet_cs:
>     Accton EN2328 or compatible (id: 0x01bf, 0x2328) uses Asix chip.
>     So it works better with axnet_cs instead of pcnet_cs.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thank you.
