From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ppp: fix truesize underestimation
Date: Mon, 13 Feb 2012 16:05:29 -0500 (EST)
Message-ID: <20120213.160529.2197621914388325318.davem@davemloft.net>
References: <1329143004.2494.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758145Ab2BMVFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 16:05:53 -0500
In-Reply-To: <1329143004.2494.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Feb 2012 15:23:24 +0100

> When building frag_list, head truesize should be sum of all frag
> truesize.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
