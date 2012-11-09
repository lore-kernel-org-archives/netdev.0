From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipip: add GSO support
Date: Fri, 09 Nov 2012 17:01:37 -0500 (EST)
Message-ID: <20121109.170137.688581951584877295.davem@davemloft.net>
References: <1352404792.19779.88.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, therbert@google.com,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756278Ab2KIWBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 17:01:39 -0500
In-Reply-To: <1352404792.19779.88.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Nov 2012 11:59:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 6b78f16e4b (gre: add GSO support) we added GSO support to GRE
> tunnels.
> 
> This patch does the same for IPIP tunnels.
> 
> Performance of single TCP flow over an IPIP tunnel is increased by 40%
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
