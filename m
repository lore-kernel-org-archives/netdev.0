From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet_diag: use sock_gen_put()
Date: Thu, 17 Oct 2013 15:02:33 -0400 (EDT)
Message-ID: <20131017.150233.1486924764985525189.davem@davemloft.net>
References: <1381506889.4971.104.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759041Ab3JQTCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:02:38 -0400
In-Reply-To: <1381506889.4971.104.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 11 Oct 2013 08:54:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP listener refactoring, part 6 :
> 
> Use sock_gen_put() from inet_diag_dump_one_icsk() for future
> SYN_RECV support.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
