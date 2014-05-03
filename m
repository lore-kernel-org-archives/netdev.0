From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove in_flight parameter from
 cong_avoid() methods
Date: Sat, 03 May 2014 19:23:28 -0400 (EDT)
Message-ID: <20140503.192328.1369747883739909134.davem@davemloft.net>
References: <1399090685.2140.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbaECXXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 19:23:33 -0400
In-Reply-To: <1399090685.2140.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 May 2014 21:18:05 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit e114a710aa505 ("tcp: fix cwnd limited checking to improve
> congestion control") obsoleted in_flight parameter from
> tcp_is_cwnd_limited() and its callers.
> 
> This patch does the removal as promised.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
