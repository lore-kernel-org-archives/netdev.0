From: David Miller <davem@davemloft.net>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Sun, 06 Sep 2009 02:01:24 -0700 (PDT)
Message-ID: <20090906.020124.263607203.davem@davemloft.net>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>
	<20090905.002705.16361217.davem@davemloft.net>
	<4AA29988.2090100@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44332
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752398AbZIFJBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2009 05:01:08 -0400
In-Reply-To: <4AA29988.2090100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 05 Sep 2009 19:02:00 +0200

> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Fri,  4 Sep 2009 18:41:12 +0200 (MEST)
>> 
>>> Any comments and test results welcome :)
>> 
>> This looks really nice.  I have them already checked into my
>> local net-next-2.6 tree and will push them out after I do
>> some multiqueue testing with NIU.
> 
> Thanks. Attached is a small fix on top hat fixes inverted logic
> in mq_destroy().

I've intesgrated this into patch 7, thanks!
