From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Netfilter fixes for net
Date: Mon, 27 Apr 2015 23:13:49 -0400 (EDT)
Message-ID: <20150427.231349.1619965797196652700.davem@davemloft.net>
References: <1430160117-21150-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbbD1DNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 23:13:51 -0400
In-Reply-To: <1430160117-21150-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 27 Apr 2015 20:41:55 +0200

> The following patchset contains Netfilter fixes for your net tree,
> they are:
> 
> 1) Fix a crash in nf_tables when dictionaries are used from the ruleset,
>    due to memory corruption, from Florian Westphal.
> 
> 2) Fix another crash in nf_queue when used with br_netfilter. Also from
>    Florian.
> 
> Both fixes are related to new stuff that got in 4.0-rc.

Pulled, thanks Pablo.
