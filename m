From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix some sparse errors
Date: Tue, 17 Jan 2012 10:32:21 -0500 (EST)
Message-ID: <20120117.103221.467073261870479832.davem@davemloft.net>
References: <1326778059.2564.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547Ab2AQPcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:32:23 -0500
In-Reply-To: <1326778059.2564.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jan 2012 06:27:39 +0100

> make C=2 CF="-D__CHECK_ENDIAN__" M=net
> 
> And fix flowi4_init_output() prototype for sport
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
