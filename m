From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: udp4_gro_complete() is static
Date: Tue, 09 Sep 2014 20:15:34 -0700 (PDT)
Message-ID: <20140909.201534.3078937460164135.davem@davemloft.net>
References: <1410276552.7106.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbaIJDPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 23:15:35 -0400
In-Reply-To: <1410276552.7106.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Sep 2014 08:29:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> net/ipv4/udp_offload.c:339:5: warning: symbol 'udp4_gro_complete' was
> not declared. Should it be static?
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Fixes: 57c67ff4bd92 ("udp: additional GRO support")

Applied.
