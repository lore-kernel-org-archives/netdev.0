From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] nf_tables updates for net-next
Date: Mon, 04 Nov 2013 19:49:17 -0500 (EST)
Message-ID: <20131104.194917.2150577204163052524.davem@davemloft.net>
References: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab3KEAtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 19:49:19 -0500
In-Reply-To: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon,  4 Nov 2013 23:05:16 +0100

> This batch contains fives nf_tables patches for your net-next tree,
> they are:
> 
> * Fix possible use after free in the module removal path of the
>   x_tables compatibility layer, from Dan Carpenter.
> 
> * Add filter chain type for the bridge family, from myself.
> 
> * Fix Kconfig dependencies of the nf_tables bridge family with
>   the core, from myself.
> 
> * Fix sparse warnings in nft_nat, from Tomasz Bursztyka.
> 
> * Remove duplicated include in the IPv4 family support for nf_tables,
>   from Wei Yongjun.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

Also looks fine, pulled, thanks!
