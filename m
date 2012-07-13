From: David Miller <davem@davemloft.net>
Subject: Re: [stable] tcp: drop SYN+FIN messages
Date: Thu, 12 Jul 2012 18:49:58 -0700 (PDT)
Message-ID: <20120712.184958.1901534669754870330.davem@davemloft.net>
References: <1342143978.25597.376.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	eric.dumazet@gmail.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933084Ab2GMBuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 21:50:01 -0400
In-Reply-To: <1342143978.25597.376.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 13 Jul 2012 02:46:18 +0100

> It looks like this is needed in 3.0.y and 3.2.y:
> 
> commit fdf5af0daf8019cec2396cdef8fb042d80fe71fa
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Fri Dec 2 23:41:42 2011 +0000
> 
>     tcp: drop SYN+FIN messages

Sure:

Acked-by: David S. Miller <davem@davemloft.net>
