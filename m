From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 0/6] mlx4: Fixes and enhancements to SRIOV code.
Date: Sun, 22 Jan 2012 14:23:31 -0500 (EST)
Message-ID: <20120122.142331.1772998493613978921.davem@davemloft.net>
References: <4F18721E.5040901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab2AVTXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:23:40 -0500
In-Reply-To: <4F18721E.5040901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 19 Jan 2012 21:42:22 +0200

> Hello Dave,
> 
> This is V1 of a series of enhancements and some fixes for mlx4 SRIOV code.
> Main changes are: 
> - Correct ethtool statistics report for each VF/PF.
> - The ability of each function to decide on which event queue to receive asynchronous events.
> - Bug fixes.

All applied, thanks.
