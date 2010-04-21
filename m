From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Fix various endianness glitches
Date: Tue, 20 Apr 2010 19:07:17 -0700 (PDT)
Message-ID: <20100420.190717.179901472.davem@davemloft.net>
References: <1271769504.7895.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57156
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755182Ab0DUCHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 22:07:12 -0400
In-Reply-To: <1271769504.7895.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Apr 2010 15:18:24 +0200

> Sparse can help us find endianness bugs, but we need to make some
> cleanups to be able to more easily spot real bugs.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Since this already helped you find a bug in the bridging
igmp snooping code, how can I not apply this? :-)

Applied, thanks Eric.
