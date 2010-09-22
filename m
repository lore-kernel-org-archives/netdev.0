From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: addrconf.h cleanups
Date: Tue, 21 Sep 2010 18:06:58 -0700 (PDT)
Message-ID: <20100921.180658.59681336.davem@davemloft.net>
References: <1285088259.2617.717.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755919Ab0IVBGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 21:06:39 -0400
In-Reply-To: <1285088259.2617.717.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Sep 2010 18:57:39 +0200

> - Use rcu_dereference_rtnl() in __in6_dev_get
> - kerneldoc for __in6_dev_get() and in6_dev_get()
> - Use inline functions instead of macros
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
