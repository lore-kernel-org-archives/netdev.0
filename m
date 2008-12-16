From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igmp: allow IPPROTO_IGMP sockets in netns
Date: Tue, 16 Dec 2008 15:44:42 -0800 (PST)
Message-ID: <20081216.154442.128200358.davem@davemloft.net>
References: <20080908012919.GD575@x200.localdomain>
	<4947CD09.6060605@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35310
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757338AbYLPXok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:44:40 -0500
In-Reply-To: <4947CD09.6060605@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Tue, 16 Dec 2008 16:45:13 +0100

> I was wondering what happened to this patch to support igmp socket per-netns sent by Alexey in September?
> 
> It looks like it has never been merged in net-next-2.6?
> 
> There's also this other patch sent at the same time by Alexey to make igmp proc entries per-netns that was "lost":
> 
> http://thread.gmane.org/gmane.linux.network/105226

Please make a formal resubmission if I've missed something.

That way there is no confusion about what patch I should
be adding.

Thanks.
