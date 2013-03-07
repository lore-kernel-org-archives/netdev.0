From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: uninline tcp_prequeue()
Date: Thu, 07 Mar 2013 16:23:50 -0500 (EST)
Message-ID: <20130307.162350.426791222361268256.davem@davemloft.net>
References: <1362610681.15793.205.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758785Ab3CGVXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:23:51 -0500
In-Reply-To: <1362610681.15793.205.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Mar 2013 14:58:01 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_prequeue() became too big to be inlined.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
