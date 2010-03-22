From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dev_getfirstbyhwtype() optimization
Date: Sun, 21 Mar 2010 20:39:37 -0700 (PDT)
Message-ID: <20100321.203937.135523052.davem@davemloft.net>
References: <1268947645.2894.166.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754063Ab0CVDjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 23:39:14 -0400
In-Reply-To: <1268947645.2894.166.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Mar 2010 22:27:25 +0100

> Use RCU to avoid RTNL use in dev_getfirstbyhwtype()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
