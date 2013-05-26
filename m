From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tcp: Remove 2 indentation levels in
 tcp_rcv_state_process
Date: Sat, 25 May 2013 23:23:15 -0700 (PDT)
Message-ID: <20130525.232315.77596430755126435.davem@davemloft.net>
References: <1369443834.3301.464.camel@edumazet-glaptop>
	<1369454556.2080.4.camel@joe-AO722>
	<1369454818.2080.6.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, ycheng@google.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770Ab3EZGXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 02:23:16 -0400
In-Reply-To: <1369454818.2080.6.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 24 May 2013 21:06:58 -0700

> case TCP_FIN_WAIT1 can also be simplified by reversing tests
> and adding breaks;
> 
> Add braces after case and move automatic definitions.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
