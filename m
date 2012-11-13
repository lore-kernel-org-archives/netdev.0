From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc95xx: set MII_BUSY bit to read/write PHY regs
Date: Tue, 13 Nov 2012 14:26:18 -0500 (EST)
Message-ID: <20121113.142618.1126776872142423073.davem@davemloft.net>
References: <1352196533-2674-1-git-send-email-steve.glendinning@shawell.net>
	<20121109.160850.901809648224300452.davem@davemloft.net>
	<CAKh2mn4Hm0R5vgOtx+kjjVXh9ucF649cdrXb_VVbRBN47WGr2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612Ab2KMT0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:26:20 -0500
In-Reply-To: <CAKh2mn4Hm0R5vgOtx+kjjVXh9ucF649cdrXb_VVbRBN47WGr2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve@shawell.net>
Date: Tue, 13 Nov 2012 17:44:39 +0000

>> Steve please let me know why you only submitted patch #2
>> of an apparent 2 part series.
> 
> My bad being sloppy when formatting the patch for submission, sorry.
> The first patch in my rebased tree was one you've already accepted
> into net but hadn't pulled into net-next yet.  I just sent the second
> one, and I forgot to remove the 2/2 from it.
> 
> They don't depend on each other, they're independent bugfixes.
> 
> Sorry again for the sloppyness.

Thanks for the clarification, applied, thanks.
