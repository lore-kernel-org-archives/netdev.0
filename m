From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ipv4: un-inline ip_finish_output2
Date: Fri, 12 Jun 2015 14:19:45 -0700 (PDT)
Message-ID: <20150612.141945.1987914602019285814.davem@davemloft.net>
References: <1434103942-20176-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbbFLVTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 17:19:46 -0400
In-Reply-To: <1434103942-20176-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 12 Jun 2015 12:12:22 +0200

>      text    data     bss     dec     hex filename
> old: 16527      44       0   16571    40bb net/ipv4/ip_output.o
> new: 14935      44       0   14979    3a83 net/ipv4/ip_output.o
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
