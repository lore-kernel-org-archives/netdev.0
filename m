From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.37-rc1]ipg.c: remove id [SUNDANCE, 0x1021]
Date: Thu, 18 Nov 2010 10:45:37 -0800 (PST)
Message-ID: <20101118.104537.245394940.davem@davemloft.net>
References: <20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
	<20101107001124.7d8ef6c4.ken_kawasaki@spring.nifty.jp>
	<20101114084208.b3ee991d.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40721
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760151Ab0KRSpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 13:45:12 -0500
In-Reply-To: <20101114084208.b3ee991d.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 14 Nov 2010 08:42:08 +0900

> 
> ipg.c:
>   The id [SUNDANCE, 0x1021] (=[0x13f0, 0x1021]) is defined
>   at dl2k.h and ipg.c.
>   But this device works better with dl2k driver.
>   
>   This problem is similar with the commit 
>   [25cca5352712561fba97bd37c495593d641c1d39
>   ipg: Remove device claimed by dl2k from pci id table]
>   at 11 Feb 2010.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thank you.
