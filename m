From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: Add NEXTHDR_SCTP to ipv6.h
Date: Wed, 24 Jul 2013 17:42:19 -0700 (PDT)
Message-ID: <20130724.174219.372069002030719666.davem@davemloft.net>
References: <1374554265-10611-1-git-send-email-joe@wand.net.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	horms@verge.net.au, jesse@nicira.com
To: joe@wand.net.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab3GYAmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:42:20 -0400
In-Reply-To: <1374554265-10611-1-git-send-email-joe@wand.net.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>
Date: Tue, 23 Jul 2013 13:37:45 +0900

> Signed-off-by: Joe Stringer <joe@wand.net.nz>

There is no value in adding a kernel internal define that is
completely unused.

Sorry I won't be applying this patch.
