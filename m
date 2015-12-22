From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Netfilter fixes for net
Date: Tue, 22 Dec 2015 14:55:20 -0500 (EST)
Message-ID: <20151222.145520.891923042793595638.davem@davemloft.net>
References: <1450806797-21788-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754794AbbLVTzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 14:55:21 -0500
In-Reply-To: <1450806797-21788-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 22 Dec 2015 18:53:15 +0100

> The following patchset contains two netfilter fixes:
> 
> 1) Oneliner from Florian to dump missing NFT_CT_L3PROTOCOL netlink
>    attribute, from Florian Westphal.
> 
> 2) Another oneliner for nf_tables to use skb->protocol from the new
>    netdev family, we can't assume ethernet there.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
