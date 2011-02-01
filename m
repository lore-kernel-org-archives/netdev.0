From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.38rc2-git7] axnet_cs: reduce delay time at
 ei_rx_overrun
Date: Mon, 31 Jan 2011 20:53:34 -0800 (PST)
Message-ID: <20110131.205334.112581674.davem@davemloft.net>
References: <20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
	<20110111205558.98fcab01.ken_kawasaki@spring.nifty.jp>
	<20110131061616.05b2fa6f.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40816
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754293Ab1BAEw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 23:52:59 -0500
In-Reply-To: <20110131061616.05b2fa6f.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Mon, 31 Jan 2011 06:16:16 +0900

> 
> axnet_cs:
>     mdelay of 10ms is too long at ei_rx_overrun.
>     It should be reduced to 2ms.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thank you.
