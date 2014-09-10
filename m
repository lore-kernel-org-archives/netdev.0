From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: udp6_gro_complete() is static
Date: Tue, 09 Sep 2014 20:15:19 -0700 (PDT)
Message-ID: <20140909.201519.487462555810078602.davem@davemloft.net>
References: <1410275777.7106.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbaIJDPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 23:15:20 -0400
In-Reply-To: <1410275777.7106.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Sep 2014 08:16:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> net/ipv6/udp_offload.c:159:5: warning: symbol 'udp6_gro_complete' was
> not declared. Should it be static?
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 57c67ff4bd92 ("udp: additional GRO support")
> Cc: Tom Herbert <therbert@google.com>

Applied.
