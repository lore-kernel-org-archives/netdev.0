From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 00/14] Always build GSO/GRO functionality into the
 kernel
Date: Thu, 15 Nov 2012 17:53:27 -0500 (EST)
Message-ID: <20121115.175327.1406052984585945748.davem@davemloft.net>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
	<20121115.174205.2002769827912724231.davem@davemloft.net>
	<50A57141.1000803@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab2KOWx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 17:53:29 -0500
In-Reply-To: <50A57141.1000803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 15 Nov 2012 17:48:33 -0500

> sorry, the patches were bases on net-2.6.  That's probably why you saw
> the conflicts.  I wasn't sure where they should go since they actually
> fix a long standing issue, so I bases them net-2.6.

I think even if we wanted to eventually submit this to the stable
tree(s), we should let it cook in net-next for a while because
it's on the invasive side.
