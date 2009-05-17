From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove needless (now buggy) & from
 dev->dev_addr (part2)
Date: Sun, 17 May 2009 14:00:04 -0700 (PDT)
Message-ID: <20090517.140004.153017718.davem@davemloft.net>
References: <4A0A2059.8040607@cn.fujitsu.com>
	<20090513084011.GC3517@psychotron.englab.brq.redhat.com>
	<20090514103611.d8dc2bc6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, sachinp@in.ibm.com,
	yjwei@cn.fujitsu.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755359AbZEQVAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 17:00:07 -0400
In-Reply-To: <20090514103611.d8dc2bc6.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 14 May 2009 10:36:11 +1000

> Hi Jiri,
> 
> On Wed, 13 May 2009 10:40:12 +0200 Jiri Pirko <jpirko@redhat.com> wrote:
>>
>> Missed part of "&" removal.
> 
> Also added to linux-next until Dave has time.
> 
> All three are now in my "fixes" tree.

I've put these fixes into net-next-2.6 and pushed them out to
kernel.org, so you shouldn't need to carry them in your
fixes tree any longer.

Thanks!
