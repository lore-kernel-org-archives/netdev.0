From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_unix: speedup /proc/net/unix
Date: Sat, 09 Jun 2012 19:06:57 -0700 (PDT)
Message-ID: <20120609.190657.317948158585477661.davem@davemloft.net>
References: <1339167801.6001.111.camel@edumazet-glaptop>
	<4FD2E22F.9090503@msgid.tls.msk.ru>
	<1339229420.6001.146.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjt@tls.msk.ru, netdev@vger.kernel.org, swhiteho@redhat.com,
	xemul@parallels.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab2FJCHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 22:07:04 -0400
In-Reply-To: <1339229420.6001.146.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 09 Jun 2012 10:10:20 +0200

> [PATCH net-next] af_unix: remove unix_iter_state
> 
> As pointed out by Michael Tokarev , struct unix_iter_state is no longer
> needed.
> 
> Suggested-by: Michael Tokarev <mjt@tls.msk.ru>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
