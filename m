From: Tim Hockin <thockin@hockin.org>
Subject: Re: [PATCH net-next #2 28/39] natsemi: stop using net_device.{base_addr,
 irq}.
Date: Tue, 10 Apr 2012 18:16:28 -0700
Message-ID: <CAAAKZwtAZ=zjPs6fR_UeHRt8wQy1B4sRxHXRwL+2=hVPTHjLUA@mail.gmail.com>
References: <CAAAKZwt9TUdDS6-pQ_aDAMxJ+MRTNnHxC0Fuajm_WsqjUED6wg@mail.gmail.com>
 <20120410.204202.923592889066244236.davem@davemloft.net> <CAAAKZwsVA7XxbbUfYRdC20Z0gjTG-3vAmQibA1Z5yaFdpa9jgA@mail.gmail.com>
 <20120410.211114.643908401942868800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51968 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933Ab2DKBQt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 21:16:49 -0400
Received: by yenl12 with SMTP id l12so253134yen.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 18:16:48 -0700 (PDT)
In-Reply-To: <20120410.211114.643908401942868800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 6:11 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Tim Hockin <thockin@hockin.org>
> Date: Tue, 10 Apr 2012 17:59:40 -0700
>
>> On Tue, Apr 10, 2012 at 5:42 PM, David Miller <davem@davemloft.net> =
wrote:
>>> From: Tim Hockin <thockin@hockin.org>
>>> Date: Tue, 10 Apr 2012 17:19:42 -0700
>>>
>>>> I agree. =C2=A0The patches to this driver have been very few and f=
ar
>>>> between, but even those I am largely unable to review any more.
>>>>
>>>> I'm more than willing to hand it off to someone who can do a bette=
r job of it
>>>
>>> My inclination was the mark the driver Orphan'd, which represents
>>> the current state of affairs quite accurately.
>>
>> I'm OK with that. As much as I don't like being a deadbeat, it's a
>> more accurate snapshot of this driver today.
>
> Ok, I'll push that MAINTAINERS change, thanks Tim.

I wish there were a way to say "I know a fair amount about this
device" without claiming an "M" line (send patches here).

Tim
