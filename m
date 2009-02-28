From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Marvell 88E609x switch?
Date: Sat, 28 Feb 2009 20:10:15 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0902282004340.9845@ask.diku.dk>
References: <20090227144004.GC17040@xi.wantstofly.org> <49A7FEE1.2020705@mlbassoc.com>
 <20090227145746.GD17040@xi.wantstofly.org> <49A801E6.1040502@mlbassoc.com>
 <20090227151441.GE17040@xi.wantstofly.org> <49A80606.1040508@mlbassoc.com>
 <20090227152721.GG17040@xi.wantstofly.org> <49A806C5.1010200@mlbassoc.com>
 <20090227153102.GH17040@xi.wantstofly.org> <49A80A75.8000101@mlbassoc.com>
 <20090227155224.GK17040@xi.wantstofly.org> <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>
 <49A97669.80309@mlbassoc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <jdb@comx.dk>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:35417 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752574AbZB1TKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2009 14:10:20 -0500
In-Reply-To: <49A97669.80309@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Feb 2009, Gary Thomas wrote:

> Jesper Dangaard Brouer wrote:
>>
>> On Fri, 27 Feb 2009, Lennert Buytenhek wrote:
>>> On Fri, Feb 27, 2009 at 08:44:53AM -0700, Gary Thomas wrote:
>>>
>>> Perhaps we should take this off-list..
>>
>> I'm still interrested... please Cc. me at jdb@comx.dk.
>
> Hi Jesper,
>
> Lennert and I have been working on this and we have parts of
> it working (PowerPC GIANFAR 1000Mb driver).  I can get the
> basic switch recognized and packets go out, but nothing seems
> to come back in.

Strange behavior...

If you will send me the current patches/code, then I'll use some time 
monday to look at the register settings to see if I can spot the problem, 
by corrolating with my device driver.


> I'll continue to work on this and let you know of the progress.
> Lennert is away for a few days, so the actual progress may be
> a bit slow...

Thanks for keeping me in the loop :-)

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
