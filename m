From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rename sk_clone to sk_clone_lock
Date: Tue, 08 Nov 2011 17:14:16 -0500 (EST)
Message-ID: <20111108.171416.1327733375900275256.davem@davemloft.net>
References: <1320789608.26025.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932137Ab1KHWOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 17:14:20 -0500
In-Reply-To: <1320789608.26025.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Nov 2011 23:00:08 +0100

> Make clear that sk_clone() and inet_csk_clone() return a locked socket.
> 
> Add _lock() prefix and kerneldoc.
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks for following up on this Eric.
