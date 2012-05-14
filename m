From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2012-05-14
Date: Mon, 14 May 2012 18:12:58 -0400 (EDT)
Message-ID: <20120514.181258.727456393377982041.davem@davemloft.net>
References: <20120514195508.GC2428@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757900Ab2ENWOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:14:05 -0400
In-Reply-To: <20120514195508.GC2428@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 14 May 2012 15:55:08 -0400

> This is essentially the same batch of updates for 3.5 that I originally
> offered ~1.5 weeks ago.  The difference is that I rebased the tree
> both to drop the offending bluetooth-next pull and to base on top of
> a more recent net-next in order to resolve the continuing NLA_PUT_*
> issues affecting linux-next.  I also took the opportunity to resolve
> a little merge damage resulting from a recent pull of the net tree
> into net-next.
> 
> Other highlights of this pull request include some HT enhancements
> for mac80211, an expansion of the ethtool support for cfg80211-
> and mac80211-based drivers, and some more iwlwifi refactoring.
> 
> Please let me know if there are problems!

Pulled, thanks John.
