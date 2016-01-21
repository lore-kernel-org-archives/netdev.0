From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: diag: support v4mapped sockets in
 inet_diag_find_one_icsk()
Date: Wed, 20 Jan 2016 18:51:47 -0800 (PST)
Message-ID: <20160120.185147.87243433000767870.davem@davemloft.net>
References: <1453335901.1223.337.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965022AbcAUCvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:51:47 -0500
In-Reply-To: <1453335901.1223.337.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jan 2016 16:25:01 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Lorenzo reported that we could not properly find v4mapped sockets
> in inet_diag_find_one_icsk(). This patch fixes the issue.
> 
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
