From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Netfilter fixes for net
Date: Tue, 10 May 2016 00:50:57 -0400 (EDT)
Message-ID: <20160510.005057.1121993023398331451.davem@davemloft.net>
References: <1462823523-6682-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbcEJEu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 00:50:59 -0400
In-Reply-To: <1462823523-6682-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon,  9 May 2016 21:52:00 +0200

> The following patchset contain Netfilter simple fixes for your net tree,
> two one-liner and one two-liner:
> 
> 1) Oneliner to fix missing spinlock definition that triggers
>    'BUG: spinlock bad magic on CPU#' when spinlock debugging is enabled,
>    from Florian Westphal.
> 
> 2) Fix missing workqueue cancelation on IDLETIMER removal,
>    from Liping Zhang.
> 
> 3) Fix insufficient validation of netlink of NFACCT_QUOTA in
>    nfnetlink_acct, from Phil Turnbull.

Pulled, thanks.
