From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6mr: Add sizeof verification to MRT6_ASSERT and
 MT6_PIM
Date: Mon, 26 Nov 2012 17:36:22 -0500 (EST)
Message-ID: <20121126.173622.1959097713828938262.davem@davemloft.net>
References: <1353872130.6558.17.camel@joe-AO722>
	<20121125.164036.1283541826012498001.davem@davemloft.net>
	<1353903994.2493.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab2KZWgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:36:25 -0500
In-Reply-To: <1353903994.2493.2.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 25 Nov 2012 20:26:34 -0800

> Verify the length of the user-space arguments.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next, thanks.
