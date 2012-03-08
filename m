From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/23] netfilter updates for net-next
Date: Wed, 07 Mar 2012 22:48:03 -0800 (PST)
Message-ID: <20120307.224803.1226286189972431232.davem@davemloft.net>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab2CHGtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 01:49:10 -0500
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Thu,  8 Mar 2012 02:00:49 +0100

> The following patchset contains netfilter updates for net-next:
> 
> * Updates for ipset from Jozsef Kadlecsik and Jan Engelhardt.
> * Enhancements for ctnetlink expectation support from myself.
> * The new cttimeout infrastructure for fine-grain timeout for
>   the connection tracking system.
> * Merge of ipt_LOG and ip6t_LOG to xt_LOG from Richard Weinberger.
> * A couple of cleanups for nf_ct_ecache from Tony Zelenoff.
> 
> I know, I took too long to send them, let me know if there's
> some chance to get them in.
> 
> You can pull them from:
> 
> git://1984.lsi.us.es/net-next master

Pulled, thanks.
