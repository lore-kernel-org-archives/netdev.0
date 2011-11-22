From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] atm: use SKB_TRUESIZE() in
 atm_guess_pdu2truesize()
Date: Tue, 22 Nov 2011 15:16:16 -0500 (EST)
Message-ID: <20111122.151616.1377539755421081186.davem@davemloft.net>
References: <1321941094.27077.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756001Ab1KVUQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:16:20 -0500
In-Reply-To: <1321941094.27077.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2011 06:51:34 +0100

> SKB_TRUESIZE() provides a better approximation of expected skb truesize.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
