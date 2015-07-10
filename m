From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not export tcp_init_xmit_timers()
Date: Thu, 09 Jul 2015 21:45:07 -0700 (PDT)
Message-ID: <20150709.214507.2219737597864839946.davem@davemloft.net>
References: <1436457700.24939.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbbGJEpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 00:45:07 -0400
In-Reply-To: <1436457700.24939.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jul 2015 18:01:40 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 900f65d361d3 ("tcp: move duplicate code from
> tcp_v4_init_sock()/tcp_v6_init_sock()"), we no longer
> need to export tcp_init_xmit_timers()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Applied, thanks.
