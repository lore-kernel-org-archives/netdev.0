From: Tim Hockin <thockin@hockin.org>
Subject: Re: [PATCH net-next #2 28/39] natsemi: stop using net_device.{base_addr,
 irq}.
Date: Tue, 10 Apr 2012 17:19:42 -0700
Message-ID: <CAAAKZwt9TUdDS6-pQ_aDAMxJ+MRTNnHxC0Fuajm_WsqjUED6wg@mail.gmail.com>
References: <CAAAKZwu4D6QZ02gaRQ2pmF=tLyxjefu1c=H83cxAJq2TTgdxmA@mail.gmail.com>
 <20120410.193042.1153959183942458232.davem@davemloft.net> <CAAAKZwvRvc=6qwainJAkHCUEme+PsFY-s0PWxj9tYXwSmBcYJA@mail.gmail.com>
 <20120410.200212.1031414009653598743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51057 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab2DKAUE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 20:20:04 -0400
Received: by yenl12 with SMTP id l12so242588yen.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 17:20:04 -0700 (PDT)
In-Reply-To: <20120410.200212.1031414009653598743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I agree.  The patches to this driver have been very few and far
between, but even those I am largely unable to review any more.

I'm more than willing to hand it off to someone who can do a better job=
 of it

Tim


On Tue, Apr 10, 2012 at 5:02 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Tim Hockin <thockin@hockin.org>
> Date: Tue, 10 Apr 2012 16:39:31 -0700
>
>> OK, so that addresses that concern. :) =C2=A0Thanks.
>>
>> Overall nothing in the CL stands out as bad, except for the IO vs MM=
IO
>> BAR thing, which I can not answer with certainty any more.
>
> If you capacity to review patches to the driver for anything other
> than trivial changes is close to zero, which it appears to be, you
> might consider whether you should be listed in MAINTAINERS for it any
> long. =C2=A0And also, therefore, whether this driver should be marked
> as Maintained.
>
