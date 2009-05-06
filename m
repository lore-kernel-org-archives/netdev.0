From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] mv643xx_eth updates for 2.6.31
Date: Wed, 06 May 2009 15:37:39 -0700 (PDT)
Message-ID: <20090506.153739.57706251.davem@davemloft.net>
References: <20090506130047.GE24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49890
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757614AbZEFWhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:37:43 -0400
In-Reply-To: <20090506130047.GE24429@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Wed, 6 May 2009 15:00:47 +0200

> In this series: some more minor cleanups, and adding support for yet
> another variation of the mv643xx_eth hardware block, one which uses
> the upper queue interrupt bits for other purposes.
> 
> The last patch in the series depends on the mv643xx_eth oom fix I
> sent earlier, but as you pulled net-2.6 into net-next-2.6 just after
> applying that patch this should apply against net-next-2.6 OK.

All applied, thanks!
