From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 0/2] Allow NICs to pass Frame Checksum up the stack.
Date: Fri, 17 Jun 2011 13:58:55 -0700
Message-ID: <4DFBC00F.4000500@candelatech.com>
References: <1308339615-5866-1-git-send-email-greearb@candelatech.com>	 <BANLkTikiNT1F39XaMFWc67OuP=StmntL=g@mail.gmail.com>	 <4DFBBD83.9040300@candelatech.com> <1308344222.2831.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55098 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932205Ab1FQU7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 16:59:00 -0400
In-Reply-To: <1308344222.2831.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2011 01:57 PM, Ben Hutchings wrote:
> On Fri, 2011-06-17 at 13:48 -0700, Ben Greear wrote:
>> On 06/17/2011 01:00 PM, Micha=C5=82 Miros=C5=82aw wrote:
>>> 2011/6/17<greearb@candelatech.com>:
>>>> From: Ben Greear<greearb@candelatech.com>
>>>>
>>>> This series provides ethtool support to set and get the rx-checksu=
m
>>>> flag, and adds support to the e100 driver.
>>> [...]
>>>
>>> If you want to test the new features approach, you can shave top bi=
t
>>> off NETIF_F_GSO_MASK (there are two unused bits there). The
>>> introducing patch will be +2 lines (+1 dev.c, +1 ethtool.c),
>>> implementation in e100: 20 lines less than patch you sent, ethtool
>>> userspace changes: none (assuming
>>> http://patchwork.ozlabs.org/patch/96374/ or equivalent applied).
>>
>> Well, is that patch going in?
>>
>> How do we get more bits if we need more than two?  Totally new
>> API?
>
> See this thread:
> http://thread.gmane.org/gmane.linux.network/196684

It's idle for 11 days.  Seems dead in the water if you ask me.

Thanks,
Ben

>
> Ben.
>


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

