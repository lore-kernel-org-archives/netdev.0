From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: tw_timer_handler() is static
Date: Wed, 13 May 2015 15:21:55 -0400 (EDT)
Message-ID: <20150513.152155.38153461971518022.davem@davemloft.net>
References: <1431436976.566.67.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283AbbEMTV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:21:57 -0400
In-Reply-To: <1431436976.566.67.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 May 2015 06:22:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> tw_timer_handler() is only used from net/ipv4/inet_timewait_sock.c
> 
> Fixes: 789f558cfb36 ("tcp/dccp: get rid of central timewait timer")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
