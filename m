From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Mon, 30 Jan 2012 13:07:17 -0500 (EST)
Message-ID: <20120130.130717.348683183628737352.davem@davemloft.net>
References: <4EE32076.2020706@profihost.ag>
	<4F26571E.1010002@profihost.ag>
	<20120130171215.GA11508@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.priebe@profihost.ag, eric.dumazet@gmail.com, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784Ab2A3SIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 13:08:46 -0500
In-Reply-To: <20120130171215.GA11508@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Mon, 30 Jan 2012 09:12:15 -0800

> On Mon, Jan 30, 2012 at 09:38:54AM +0100, Stefan Priebe - Profihost AG wrote:
>> Hi David, Hi Greg, Hi List,
>> 
>> Am 10.12.2011 10:03, schrieb Stefan Priebe:
>> > Am 09.12.2011 20:21, schrieb David Miller:
>> >> From: Stefan Priebe<s.priebe@profihost.ag>
>> >> Date: Fri, 09 Dec 2011 20:01:26 +0100
>> >>
>> >>> any news on that? Systems still crashing every now and then. 3.0.13
>> >>> was released today but i haven't seen any of them.
>> >>
>> >> I only had time to submit these fixes for 3.1.x-stable, you'll just
>> >> have to be incredibly patient.
>> 
>> this bug sadly still makes the actual STABLE tree of the kernel
>> unusable. I mean nearly everbody uses TCP/IP.
> 
> "this bug"?

Actually, like Greg, I cannot figure out which fix you are referring
to.

You haven't provided enough context, and even searching into the
mailing list archives I cannot find a link into the real history of
this discussion thread.
