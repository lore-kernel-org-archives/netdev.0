From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use skb_reset_mac_len() in
 dev_gro_receive()
Date: Fri, 15 Feb 2013 15:37:06 -0500 (EST)
Message-ID: <20130215.153706.309028075830322767.davem@davemloft.net>
References: <1360899108.6884.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab3BOUhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 15:37:07 -0500
In-Reply-To: <1360899108.6884.77.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Feb 2013 19:31:48 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We no longer need to use mac_len, lets cleanup things.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
