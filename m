From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] Sometimes the ISDN chip only controls the D-channel
Date: Thu, 03 May 2012 02:50:59 -0400 (EDT)
Message-ID: <20120503.025059.1771068683530938115.davem@davemloft.net>
References: <1335613404-10187-4-git-send-email-kkeil@linux-pingi.de>
	<20120501.133007.569588994121475807.davem@davemloft.net>
	<4FA2265D.6040000@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459Ab2ECGvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 02:51:07 -0400
In-Reply-To: <4FA2265D.6040000@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Thu, 03 May 2012 08:31:57 +0200

> I did put the additional PCM infrastructure in this series, because
> the approval test was done with it in place.
> I did plan the update of the low level drivers in a separate patchset
> from the beginning.
> 
> What do you prefer, adding the driver part now, as additional patch, or
> removing this additional infrastruckture part and submit it in a later
> series ?

I feel like I'm talking to a wall.

A patch should do one, and only one thing.  It should not have
changes which are unrelated to that one thing.

What part of this is so hard to understand?

To make matters worse, you didn't even make a mention of those
unrelated changes in your commit message.

So that patch was bogus on at least two counts.
