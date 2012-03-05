From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: Adjust min age inc for HZ > 256
Date: Mon, 05 Mar 2012 03:24:10 -0500 (EST)
Message-ID: <20120305.032410.1729877140582678194.davem@davemloft.net>
References: <20120304210350.629ec5c6@nehalam.linuxnetplumber.net>
	<20120305.000921.1233132850153467742.davem@davemloft.net>
	<OF2C9B7723.897FDDA7-ONC12579B8.002D1A5A-C12579B8.002D3A31@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab2CEIYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 03:24:21 -0500
In-Reply-To: <OF2C9B7723.897FDDA7-ONC12579B8.002D1A5A-C12579B8.002D3A31@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Date: Mon, 5 Mar 2012 09:14:00 +0100

> David Miller <davem@davemloft.net> wrote on 2012/03/05 06:09:21:
>>
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Sun, 4 Mar 2012 21:03:50 -0800
>>
>> > I don't understand why this is required.
>>
>> And I don't understand why it takes nearly a week to review a one line
>> patch like this.
>>
>> If you don't say anything I'm going to just apply it after a few days,
>> which is what I did here already.
>>
>> Me applying it should never be your trigger to review the patch, yet I
>> see this happen all the time.  What do you think I was waiting for
>> these past 5 days, divine intervention?
> 
> hmm, does this mean you "unapplied" the patch now?

I can't, it's now in the permanent record so I can't remove it.

At best I can apply a revert patch, but you guys are still discussing
this so I have no idea whether that's even necessary or not.
