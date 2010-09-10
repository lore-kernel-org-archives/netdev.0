From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] fib: cleanups
Date: Fri, 10 Sep 2010 12:32:29 -0700 (PDT)
Message-ID: <20100910.123229.124071310.davem@davemloft.net>
References: <1284111148.24675.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52409
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753616Ab0IJTcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 15:32:11 -0400
In-Reply-To: <1284111148.24675.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Sep 2010 11:32:28 +0200

> Use rcu_dereference_rtnl() helper
> 
> Change hard coded constants in fib_flag_trans()
>  7 -> RTN_UNREACHABLE
>  8 -> RTN_PROHIBIT
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
