From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.35-rc3] smc91c92_cs: fix the problem that
 lan & modem does not work simultaneously
Date: Fri, 25 Jun 2010 21:32:04 -0700 (PDT)
Message-ID: <20100625.213204.123981977.davem@davemloft.net>
References: <20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
	<20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751079Ab0FZEbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:31:52 -0400
In-Reply-To: <20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 20 Jun 2010 10:24:27 +0900

> 
> smc91c92_cs:
>   Fix the problem that lan & modem does not work simultaneously
>   in the Megahertz multi-function card.
>   We need to write MEGAHERTZ_ISR to retrigger interrupt.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied.
