From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: get_cookie_sock() consolidation
Date: Sun, 07 Jun 2015 15:20:03 -0700 (PDT)
Message-ID: <20150607.152003.518071476299629494.davem@davemloft.net>
References: <1433467843.1895.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbFGWUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 18:20:03 -0400
In-Reply-To: <1433467843.1895.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Jun 2015 18:30:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> IPv4 and IPv6 share same implementation of get_cookie_sock(),
> and there is no point inlining it.
> 
> We add tcp_ prefix to the common helper name and export it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
