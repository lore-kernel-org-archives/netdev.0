From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ping: remove some sparse errors
Date: Wed, 14 Dec 2011 13:35:20 -0500 (EST)
Message-ID: <20111214.133520.2236842562036905556.davem@davemloft.net>
References: <1323870688.2334.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757958Ab1LNSfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 13:35:24 -0500
In-Reply-To: <1323870688.2334.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Dec 2011 14:51:28 +0100

> net/ipv4/sysctl_net_ipv4.c:78:6: warning: symbol 'inet_get_ping_group_range_table'
> was not declared. Should it be static?
> 
> net/ipv4/sysctl_net_ipv4.c:119:31: warning: incorrect type in argument 2
> (different signedness)
> net/ipv4/sysctl_net_ipv4.c:119:31: expected int *range
> net/ipv4/sysctl_net_ipv4.c:119:31: got unsigned int *<noident>
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
