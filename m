From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: don't poll NV event 36
Date: Thu, 25 Dec 2008 18:08:00 -0800 (PST)
Message-ID: <20081225.180800.233126632.davem@davemloft.net>
References: <1229888646.3050.4.camel@johannes>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com, arjan@infradead.org,
	manfred@colorfullife.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752537AbYLZCH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 21:07:57 -0500
In-Reply-To: <1229888646.3050.4.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 21 Dec 2008 20:44:06 +0100

> Polling doesn't seem to be necessary on my hardware, at
> least I haven't seen any bad effects testing it a while.
> Remove the polling so the CPU doesn't have to wake up a
> hundred times per second.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks Johannes.
