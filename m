From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] perf: net_dropmonitor: Make it work and make it
 fast
Date: Wed, 22 May 2013 15:11:12 -0700 (PDT)
Message-ID: <20130522.151112.1309391168644175099.davem@davemloft.net>
References: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
	<20130521133355.GA3613@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, a.p.zijlstra@chello.nl, paulus@samba.org,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276Ab3EVWLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 18:11:13 -0400
In-Reply-To: <20130521133355.GA3613@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 21 May 2013 09:33:56 -0400

> On Tue, May 21, 2013 at 01:42:56AM +0100, Ben Hutchings wrote:
>> Somewhat surprisingly, the net_dropmonitor reporting script doesn't work
>> at all.  This series fixes it and then makes it slightly more efficient.
>> 
>> Ben.
>> 
> It worked fine when I first submitted it.  I wonder if there was a paramter
> order change at some point that I wasn't CC'ed on.
> 
> Either way, this all looks good.  Thanks Ben.
> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Series applied, thanks.
