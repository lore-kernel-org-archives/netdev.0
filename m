From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: include/net/sock.h cleanup
Date: Thu, 17 May 2012 04:50:55 -0400 (EDT)
Message-ID: <20120517.045055.1772646060253557310.davem@davemloft.net>
References: <1337244495.29313.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759657Ab2EQIu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 04:50:58 -0400
In-Reply-To: <1337244495.29313.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 May 2012 10:48:15 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> bool/const conversions where possible
> 
> __inline__ -> inline
> 
> space cleanups
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
