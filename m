From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Sun, 18 Dec 2011 00:19:25 -0500 (EST)
Message-ID: <20111218.001925.2108645748994734084.davem@davemloft.net>
References: <4EED3A3D.9080503@gentoo.org>
	<20111217.215630.640392276998191183.davem@davemloft.net>
	<4EED6DED.50308@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: kumba@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab1LRFTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 00:19:33 -0500
In-Reply-To: <4EED6DED.50308@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joshua Kinard <kumba@gentoo.org>
Date: Sat, 17 Dec 2011 23:37:01 -0500

> MACE Ethernet only ever appears on the SGI O2 systems.

That has no bearing on my feedback, we simply do not put non-portable
code like this into the tree at this point.

Just because this driver has been maintained in an non-portable manner
up to this point, doesn't mean we continue doing that.
