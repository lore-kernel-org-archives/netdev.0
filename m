From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] ipv6/ila: fix nlsize calculation for lwtunnel
Date: Mon, 25 Apr 2016 16:47:23 -0400 (EDT)
Message-ID: <20160425.164723.789185717396516518.davem@davemloft.net>
References: <1461340682-31568-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964928AbcDYUr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:47:26 -0400
In-Reply-To: <1461340682-31568-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 22 Apr 2016 17:58:02 +0200

> The handler 'ila_fill_encap_info' adds one attribute: ILA_ATTR_LOCATOR.
> 
> Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
> CC: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> Tom, when I read the comment, I feel I'm misssing something, but what?

Tom please take a look at this, thanks.
