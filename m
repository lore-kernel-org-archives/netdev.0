From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipv6: correct return on ipv6_rcv() packet drop
Date: Tue, 07 Jul 2009 18:34:40 -0700 (PDT)
Message-ID: <20090707.183440.214607665.davem@davemloft.net>
References: <20090707185015.391c893f.lk-netdev@lk-netdev.nosense.org>
	<20090707.085219.101591166.davem@davemloft.net>
	<20090708063413.fe18dc6f.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: lk-netdev@lk-netdev.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755323AbZGHBeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 21:34:37 -0400
In-Reply-To: <20090708063413.fe18dc6f.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Date: Wed, 8 Jul 2009 06:34:13 +0930

> On Tue, 07 Jul 2009 08:52:19 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
>> Date: Tue, 7 Jul 2009 18:50:15 +0930
>> 
>> > Today I came across this earlier partial version of what I
>> > independently identified and submitted, so I shouldn't get full credit
>> > for it:
>> > 
>> > http://lkml.indiana.edu/hypermail/linux/kernel/0804.1/2393.html
>> 
>> I already pushed your change out to my public tree so we're
>> past the point of being able to modify the commit message.
>> 
>> We'll just try to be more careful next time.
> 
> Is there an easier way to avoid this, other than a google search? I
> happened to discover it by doing a google search when I was at work, to
> see how my patch was going. I suppose possibly not.

Perhaps some day we can have more powerful searching mechanisms
on patchwork, who knows.

Feel free to discuss such ideas on the patchwork mailing list:

	https://ozlabs.org/mailman/listinfo/patchwork
