From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next-2.6] net: relax dst refcnt in input path
Date: Thu, 06 Aug 2009 22:09:55 -0700 (PDT)
Message-ID: <20090806.220955.251872775.davem@davemloft.net>
References: <4A6732D6.90809@gmail.com>
	<20090806.133518.263376332.davem@davemloft.net>
	<4A7BB622.2070007@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, markmc@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34796
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753228AbZHGFJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 01:09:46 -0400
In-Reply-To: <4A7BB622.2070007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Aug 2009 07:05:38 +0200

> I'll respin patch anyway since commit bbd8a0d3a3b65d341437f8b99c828fa5cc29c739
> (net: Avoid enqueuing skb for default qdiscs)
> changed too many things, when I'll come back from vacations in two weeks.

That's fine.

> Or if you prefer, I might submit it today (my vacations start tomorrow), but
> please dont apply it while I cannot react to any bug report :)

Take your time, there is no rush.
