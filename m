From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: two vzalloc() cleanups
Date: Mon, 19 Dec 2011 16:01:45 -0500 (EST)
Message-ID: <20111219.160145.1637643517932172033.davem@davemloft.net>
References: <1324070255.2621.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab1LSVBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:01:49 -0500
In-Reply-To: <1324070255.2621.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Dec 2011 22:17:35 +0100

> We can use vzalloc() helper now instead of __vmalloc() trick
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
