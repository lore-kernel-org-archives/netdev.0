From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] netxen: write IP address to firmware when
 using bonding
Date: Wed, 03 Oct 2012 14:38:55 -0400 (EDT)
Message-ID: <20121003.143855.520640065174429479.davem@davemloft.net>
References: <1348562883-14780-1-git-send-email-nikolay@redhat.com>
	<1349169386-18391-1-git-send-email-nikolay@redhat.com>
	<506C0346.8010708@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, agospoda@redhat.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310Ab2JCSi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 14:38:57 -0400
In-Reply-To: <506C0346.8010708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 03 Oct 2012 11:20:06 +0200

> I just synced with upstream, I've missed a few patches and it seems
> that it doesn't apply cleanly because my previous patch was
> changed before it was applied. There is one character missing from
> a comment - "/* root bus? */", in upstream it was changed to
> /* root bus */.
> ("netxen: check for root bus in netxen_mask_aer_correctable")
> 
> About the rest, after QLogic test the functionality I'll clean-up the
> empty lines and re-send it.

Can you please not quote an entire patch just to make a small series
of comments?

Just quote the exact relevant portions of the patch if you want to
specifically make comments about something.

Quoting the entire patch is extremely bad netiquette, wastes
bandwidth, and everyone on the list has to receive a whole new copy of
the entire patch again for no good reason.
