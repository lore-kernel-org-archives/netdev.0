From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] Second Round of IPVS Fixes for v4.7
Date: Mon, 11 Jul 2016 12:04:42 +0200
Message-ID: <20160711100442.GB6412@salvia>
References: <1467916222-15595-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41915 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030622AbcGKKEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 06:04:47 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 3DE8717AB6D
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 12:04:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 20671100799
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 12:04:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A3383B505B
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 12:04:43 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1467916222-15595-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 08:30:21PM +0200, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this IPVS fix for v4.7.
> 
> The fix from Quentin Armitage allows the backup sync daemon to
> be bound to a link-local mcast IPv6 address as is already the case
> for IPv4.
> 
> The following changes since commit 62131e5d735226074cba53095545d76b491e5003:
> 
>   netfilter: nft_meta: set skb->nf_trace appropriately (2016-06-23 14:15:33 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v4.7

Also pulled, thanks.
