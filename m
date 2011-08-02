From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add kerneldoc to skb_copy_bits()
Date: Mon, 01 Aug 2011 18:03:19 -0700 (PDT)
Message-ID: <20110801.180319.51331125222324108.davem@davemloft.net>
References: <1312000651.2873.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab1HBBDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 21:03:21 -0400
In-Reply-To: <1312000651.2873.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 Jul 2011 06:37:31 +0200

> Since skb_copy_bits() is called from assembly, add a fat comment to make
> clear we should think twice before changing its prototype.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
