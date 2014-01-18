From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] parisc: fix SO_MAX_PACING_RATE typo
Date: Fri, 17 Jan 2014 18:11:23 -0800 (PST)
Message-ID: <20140117.181123.1899249516684219420.davem@davemloft.net>
References: <1389898146.31367.413.camel@edumazet-glaptop2.roam.corp.google.com>
	<52D82A7A.3090106@redhat.com>
	<1389899712.31367.419.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, msekleta@redhat.com, netdev@vger.kernel.org,
	mtk.manpages@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbaARCLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:11:23 -0500
In-Reply-To: <1389899712.31367.419.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Jan 2014 11:15:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> SO_MAX_PACING_RATE definition on parisc got a typo.
> Its not too late to fix it, before 3.13 is official.
> 
> Fixes: 62748f32d501 ("net: introduce SO_MAX_PACING_RATE")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
