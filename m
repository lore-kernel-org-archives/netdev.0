From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.37-rc1] axnet_cs: fix resume problem for
 some Ax88790 chip
Date: Fri, 12 Nov 2010 14:01:01 -0800 (PST)
Message-ID: <20101112.140101.13754308.davem@davemloft.net>
References: <20100829074501.946ebcb8.ken_kawasaki@spring.nifty.jp>
	<20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
	<20101107001124.7d8ef6c4.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58200
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932795Ab0KLWAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 17:00:36 -0500
In-Reply-To: <20101107001124.7d8ef6c4.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 7 Nov 2010 00:11:24 +0900

> 
> axnet_cs:
>     Some Ax88790 chip need to reinitialize the CISREG_CCSR register
>     after resume.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thank you.
