From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] ipv6: use flag instead of u16 for hop in
 inet6_skb_parm
Date: Thu, 09 Jul 2015 15:09:37 -0700 (PDT)
Message-ID: <20150709.150937.189941526500062648.davem@davemloft.net>
References: <1436391132-5199-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbbGIWJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:09:38 -0400
In-Reply-To: <1436391132-5199-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  8 Jul 2015 23:32:12 +0200

> Hop was always either 0 or sizeof(struct ipv6hdr).
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Looks good, applied, thanks Florian.
