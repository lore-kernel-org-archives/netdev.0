From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netfilter updates for net tree
Date: Thu, 23 Feb 2012 00:20:47 -0500 (EST)
Message-ID: <20120223.002047.1508425424024898432.davem@davemloft.net>
References: <1329955346-2615-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab2BWFV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 00:21:57 -0500
In-Reply-To: <1329955346-2615-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Thu, 23 Feb 2012 01:02:22 +0100

> The following are four fixes for your net tree:
> 
> * One fix for NFQUEUE if used in bridge mode when GRO/GSO skbs
>   are enqueued from Florian Westphal.
> 
> * One fix from Joerg Willmann to fix wrong alignment in ebtables
>   on PPC.
> 
> * One fix for soft lockup for ctnetlink from Jozsef Kadlecsik.
> 
> * One fix for IPVS from Simon Horman.
> 
> Please, pull these changes from:
> 
> 	git://1984.lsi.us.es/net nf

Pulled, thanks Pablo.
