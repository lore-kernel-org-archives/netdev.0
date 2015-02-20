From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter/IPVS fixes for net
Date: Fri, 20 Feb 2015 17:36:41 -0500 (EST)
Message-ID: <20150220.173641.1875151436508088235.davem@davemloft.net>
References: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759AbbBTWgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:36:43 -0500
In-Reply-To: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 19 Feb 2015 19:19:16 +0100

> The following patchset contains updates for your net tree, they are:
> 
> 1) Fix removal of destination in IPVS when the new mixed family support
>    is used, from Alexey Andriyanov via Simon Horman.
> 
> 2) Fix module refcount undeflow in nft_compat when reusing a match /
>    target.
> 
> 3) Fix iptables-restore when the recent match is used with a new hitcount
>    that exceeds threshold, from Florian Westphal.
> 
> 4) Fix stack corruption in xt_socket due to using stack storage to save
>    the inner IPv6 header, from Eric Dumazet.
> 
> I'll follow up soon with another batch with more fixes that are still
> cooking.

Pulled, thanks Pablo.
