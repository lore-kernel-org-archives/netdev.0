From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] IPVS updates for net-next tree
Date: Fri, 26 Oct 2012 14:50:06 -0400 (EDT)
Message-ID: <20121026.145006.1534097522946444293.davem@davemloft.net>
References: <1351243478-4852-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974Ab2JZSuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 14:50:07 -0400
In-Reply-To: <1351243478-4852-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Fri, 26 Oct 2012 11:24:30 +0200

> The following changeset contains updates for IPVS from Jesper Dangaard
> Brouer that did not reach the previous merge window in time.
> 
> More specifically, updates to improve IPv6 support in IPVS. More
> relevantly, some of the existing code performed wrong handling of the
> extensions headers and better fragmentation handling.
> 
> Jesper promised more follow-up patches to refine this after this batch
> hits net-next. Yet to come.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Pulled, thanks.
