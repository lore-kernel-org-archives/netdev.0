From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use IS_ENABLED(CONFIG_IPV6)
Date: Sun, 11 Dec 2011 18:34:58 -0500 (EST)
Message-ID: <20111211.183458.635127430083195240.davem@davemloft.net>
References: <1323514931.4016.17.camel@edumazet-laptop>
	<20111210.131555.2025649575447940902.davem@davemloft.net>
	<1323546511.4016.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab1LKXfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 18:35:01 -0500
In-Reply-To: <1323546511.4016.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 10 Dec 2011 20:48:31 +0100

> 
> Instead of testing defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
