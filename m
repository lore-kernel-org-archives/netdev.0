From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: fix truesize underestimation
Date: Mon, 13 Feb 2012 16:05:18 -0500 (EST)
Message-ID: <20120213.160518.2240135637809669737.davem@davemloft.net>
References: <1329142160.2494.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755908Ab2BMVF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 16:05:27 -0500
In-Reply-To: <1329142160.2494.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Feb 2012 15:09:20 +0100

> skb_gro_receive() doesnt update truesize properly when adding one skb to
> frag_list.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
