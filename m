From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_frag: struct inet_frags match() method
 returns a bool
Date: Fri, 18 May 2012 01:40:41 -0400 (EDT)
Message-ID: <20120518.014041.1469329207243118782.davem@davemloft.net>
References: <1337313433.3403.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054Ab2ERFkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 01:40:43 -0400
In-Reply-To: <1337313433.3403.73.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 May 2012 05:57:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> - match() method returns a boolean
> - return (A && B && C && D) -> return A && B && C && D
> - fix indentation
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
