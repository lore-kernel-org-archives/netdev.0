From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove csummode in ip6_append_data()
Date: Fri, 18 May 2012 13:31:52 -0400 (EDT)
Message-ID: <20120518.133152.624538079118445188.davem@davemloft.net>
References: <1337355476.7029.46.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965629Ab2ERRbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 13:31:55 -0400
In-Reply-To: <1337355476.7029.46.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 May 2012 17:37:56 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> csummode variable is always CHECKSUM_NONE in ip6_append_data()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
