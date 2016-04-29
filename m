From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/8] Fix Tunnel features and enable GSO
 partial for Mellanox adapters
Date: Fri, 29 Apr 2016 13:31:07 -0400 (EDT)
Message-ID: <20160429.133107.1317675802100306452.davem@davemloft.net>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: talal@mellanox.com, netdev@vger.kernel.org, galp@mellanox.com,
	ogerlitz@mellanox.com, eranbe@mellanox.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53906 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbcD2RbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 13:31:09 -0400
In-Reply-To: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Mon, 25 Apr 2016 11:30:54 -0700

> This patch series is meant to allow us to get the best performance possible
> for Mellanox ConnectX-3/4 adapters in terms of VXLAN tunnels.

I'm going to mark this as "deferred" in patchwork, so Alex why don't you just
respin these and repost next week when you get final feedback from the Mellanox
folks?

THanks.
