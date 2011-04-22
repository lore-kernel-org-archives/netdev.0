From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inet: constify ip headers and in6_addr
Date: Fri, 22 Apr 2011 11:04:37 -0700 (PDT)
Message-ID: <20110422.110437.193728431.davem@davemloft.net>
References: <1303483982.3134.131.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57777
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756418Ab1DVSFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 14:05:12 -0400
In-Reply-To: <1303483982.3134.131.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 Apr 2011 16:53:02 +0200

> Add const qualifiers to structs iphdr, ipv6hdr and in6_addr pointers
> where possible, to make code intention more obvious.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks!
