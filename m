From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: napi_frags_skb() is static
Date: Sat, 19 May 2012 02:51:12 -0400 (EDT)
Message-ID: <20120519.025112.295895787324732867.davem@davemloft.net>
References: <1337410146.7029.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab2ESGvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 02:51:14 -0400
In-Reply-To: <1337410146.7029.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 08:49:06 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> No need to export napi_frags_skb()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
