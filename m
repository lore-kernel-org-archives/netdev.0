From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] net/mlx4_en: DCB QoS support
Date: Tue, 20 Mar 2012 15:58:26 -0400 (EDT)
Message-ID: <20120320.155826.2251812080980877732.davem@davemloft.net>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
	<4F686A07.4070401@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	roland@purestorage.com, oren@mellanox.com, yevgenyp@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755917Ab2CTT6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 15:58:39 -0400
In-Reply-To: <4F686A07.4070401@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 20 Mar 2012 13:29:11 +0200

> Patches 7-8 who deal with the interaction between the kernel HW QoS
> constructs to the queue selection logic are still under discussion
> with John and some changes might be needed there.
> At this point, we ask for patches 1-6 to be pulled in, and continue
> the discussion from there.

That's not how this works.

I toss out an entire series when some of the patches need changes.

You thus must resubmit freshly any subset you want applied.
