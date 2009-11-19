From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netsched: Allow var_sk_bound_if meta to
 work on all namespaces
Date: Wed, 18 Nov 2009 22:29:33 -0800 (PST)
Message-ID: <20091118.222933.14546474.davem@davemloft.net>
References: <4B048A41.7090103@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751129AbZKSG3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 01:29:16 -0500
In-Reply-To: <4B048A41.7090103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Nov 2009 00:58:57 +0100

> This fix can probably wait 2.6.33, or should use another patch
> if needed in 2.6.32 (no get_dev_by_index_rcu() before 2.6.33)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll add this to net-next-2.6, thanks Eric.
