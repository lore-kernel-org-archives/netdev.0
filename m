From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 28/39] natsemi: stop using
 net_device.{base_addr, irq}.
Date: Tue, 10 Apr 2012 21:11:14 -0400 (EDT)
Message-ID: <20120410.211114.643908401942868800.davem@davemloft.net>
References: <CAAAKZwt9TUdDS6-pQ_aDAMxJ+MRTNnHxC0Fuajm_WsqjUED6wg@mail.gmail.com>
	<20120410.204202.923592889066244236.davem@davemloft.net>
	<CAAAKZwsVA7XxbbUfYRdC20Z0gjTG-3vAmQibA1Z5yaFdpa9jgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933Ab2DKBMS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 21:12:18 -0400
In-Reply-To: <CAAAKZwsVA7XxbbUfYRdC20Z0gjTG-3vAmQibA1Z5yaFdpa9jgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tim Hockin <thockin@hockin.org>
Date: Tue, 10 Apr 2012 17:59:40 -0700

> On Tue, Apr 10, 2012 at 5:42 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: Tim Hockin <thockin@hockin.org>
>> Date: Tue, 10 Apr 2012 17:19:42 -0700
>>
>>> I agree. =A0The patches to this driver have been very few and far
>>> between, but even those I am largely unable to review any more.
>>>
>>> I'm more than willing to hand it off to someone who can do a better=
 job of it
>>
>> My inclination was the mark the driver Orphan'd, which represents
>> the current state of affairs quite accurately.
>=20
> I'm OK with that. As much as I don't like being a deadbeat, it's a
> more accurate snapshot of this driver today.

Ok, I'll push that MAINTAINERS change, thanks Tim.
