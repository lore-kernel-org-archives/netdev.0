From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net v2] 6lowpan: rework data fetching from skb
Date: Sat, 12 May 2012 23:28:21 -0400 (EDT)
Message-ID: <20120512.232821.1019571950434617908.davem@davemloft.net>
References: <4fabc166.9208cc0a.4de8.ffff9211@mx.google.com>
	<1336748290-25649-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab2EMD21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 23:28:27 -0400
In-Reply-To: <1336748290-25649-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This and your other patch are not appropriate this late in
the -rc series, and Linus has ratched up his standards even
higher with todays' RC release.

You'll need to resubmit these for net-next.
