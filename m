From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Mon, 09 Dec 2013 20:23:21 -0500 (EST)
Message-ID: <20131209.202321.2134510956668375662.davem@davemloft.net>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
	<20131209.195854.223825767831436997.davem@davemloft.net>
	<52A66C0D.4050409@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab3LJBXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:23:23 -0500
In-Reply-To: <52A66C0D.4050409@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Tue, 10 Dec 2013 09:19:09 +0800

> How it could be usable first and then useful for someone before my fix
> 9e921193884dd85b4cd68aa18598d8c2f9ad85b9
> ({pktgen, xfrm} Correct xfrm state lock usage when transforming)???
> 
> Do you really know what this fix does?

Maybe they didn't care about the checksum being correct in the
testbed they were using.

I know Jamal used it when he added the feature.
