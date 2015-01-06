From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/6] net: allow setting congctl via routing
 table
Date: Mon, 05 Jan 2015 22:55:51 -0500 (EST)
Message-ID: <20150105.225551.1030708062993095793.davem@davemloft.net>
References: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbbAFDzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 22:55:54 -0500
In-Reply-To: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  5 Jan 2015 23:57:42 +0100

> This is the second part of our work and allows for setting the congestion
> control algorithm via routing table. For details, please see individual
> patches.
> 
> Since patch 1 is a bug fix, we suggest applying patch 1 to net, and then
> merging net into net-next, for example, and following up with the remaining
> feature patches wrt dependencies.
> 
> Joint work with Florian Westphal, suggested by Hannes Frederic Sowa.
> 
> Patch for iproute2 is available under [1], but will be reposted with along
> with the man-page update when this set hits net-next.
> 
>   [1] http://patchwork.ozlabs.org/patch/418149/

Looks good, series applied, thanks!
