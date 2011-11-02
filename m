From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Tue, 01 Nov 2011 20:34:30 -0400 (EDT)
Message-ID: <20111101.203430.110242050755204948.davem@davemloft.net>
References: <1319360590.6180.75.camel@edumazet-laptop>
	<20111024.030203.404195331212003955.davem@davemloft.net>
	<20111101185022.b156ea957baf286f1bf00f9c@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, eric.dumazet@gmail.com, zheng.z.yan@intel.com,
	netdev@vger.kernel.org
To: kim.phillips@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966Ab1KBAej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 20:34:39 -0400
In-Reply-To: <20111101185022.b156ea957baf286f1bf00f9c@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Phillips <kim.phillips@freescale.com>
Date: Tue, 1 Nov 2011 18:50:22 -0500

> -stable maintainers, please consider the following two upstream
> commits for inclusion in upcoming v3.0.x [1] stable releases:

I submit networking stable fixes as needed, so please make such
requests to me.

I haven't submitted this change yet because I want it to sit a bit
longer in Linus's tree to make sure there aren't any unwanted
side-effects.
