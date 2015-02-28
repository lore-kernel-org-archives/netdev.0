From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tcp: tso improvements
Date: Sat, 28 Feb 2015 15:11:06 -0500 (EST)
Message-ID: <20150228.151106.241580356830868524.davem@davemloft.net>
References: <1424988620-10781-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbB1ULI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 15:11:08 -0500
In-Reply-To: <1424988620-10781-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 26 Feb 2015 14:10:17 -0800

> This patch serie reworks tcp_tso_should_defer() a bit
> to get less bursts, and better ECN behavior.
> 
> We also removed tso_deferred field in tcp socket.

Series applied, thanks Eric.
