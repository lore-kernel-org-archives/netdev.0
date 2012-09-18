From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4 0/2] Add rtnl_link_ops support to IPoIB
Date: Tue, 18 Sep 2012 16:12:34 -0400 (EDT)
Message-ID: <20120918.161234.1352425943440206508.davem@davemloft.net>
References: <1347551797-2495-1-git-send-email-ogerlitz@mellanox.com>
	<CAJZOPZL6cEEbyMgj+3_h-ZHf0jzNs3yF=f3uOTrKB6EO4Vx2yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754707Ab2IRUMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 16:12:37 -0400
In-Reply-To: <CAJZOPZL6cEEbyMgj+3_h-ZHf0jzNs3yF=f3uOTrKB6EO4Vx2yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Tue, 18 Sep 2012 23:07:54 +0300

> On Thu, Sep 13, 2012 at 6:56 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> This is about adding rtnl_link_ops to IPoIB, primarly addressing feedback
>> from Dave on a similar patch that was part of the eIPoIB submission.
> [...]
>> Roland, this patch is hanging out for pretty long while (few months) without
>> any comment from you, if it makes things easier, I would like to merge it through
>> net-next, makes sense?
> 
> 
> Hi Roland,
> 
> Haven't heard from you on this patch, are you picking this or it can
> get in though net-next?

Nobody has given any generic networking review to this patch yet, and given
that I'd be very disappointed if Roland went ahead and applied this.

You never need to ping people over issues like this and it's extremely
irritating that you keep doing this.

Everything you need to know is at:

http://patchwork.ozlabs.org/project/netdev/list/

And you can clearly see your patch sitting there in "Under Review"
state.

You simply need to be patient and wait for people to get to reviewing
your patch rather than forcing the issue with pings.  We track patches
in patchwork so we don't need to waste time with "pings"
