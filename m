From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netpoll: provide an IP ident in UDP frames
Date: Thu, 30 Aug 2012 12:32:38 -0400 (EDT)
Message-ID: <20120830.123238.59289912612289680.davem@davemloft.net>
References: <1345808846.29722.133.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab2H3Qcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:32:39 -0400
In-Reply-To: <1345808846.29722.133.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Aug 2012 13:47:26 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Let's fill IP header ident field with a meaningful value,
> it might help some setups.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
