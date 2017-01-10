From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large struct
 on stack"
Date: Tue, 10 Jan 2017 10:44:59 -0800
Message-ID: <CAM_iQpV0V23fndi6DOW1gu9kq+2UufHNrnfRYCME7uOOLCaX-Q@mail.gmail.com>
References: <1483985224.21472.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170109.135259.988711786570465428.davem@davemloft.net> <CAM_iQpUbcVogq7jGePkgPJ0z_J=46hnK8KcTiX1svVXr1Hoh-w@mail.gmail.com>
 <20170110.131223.748150430551443881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36518 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934153AbdAJSp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:45:26 -0500
Received: by mail-qk0-f193.google.com with SMTP id a20so24998016qkc.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:45:20 -0800 (PST)
In-Reply-To: <20170110.131223.748150430551443881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 10:12 AM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 10 Jan 2017 10:06:01 -0800
>
>> On Mon, Jan 9, 2017 at 10:52 AM, David Miller <davem@davemloft.net> wrote:
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Mon, 09 Jan 2017 10:07:04 -0800
>>>
>>>> You really should come to netdev conferences so that you understand
>>>> goals and efforts, instead of living in your cave.
>>>
>>> I completely agree with Eric.
>>>
>>> Cong we have a very serious problem with you exactly because you make
>>> quite vicious emotional statements targetted at other developers
>>> merely when they say something you disagree with.
>>
>> What emotional? Pointing out Eris's words from 4 years ago is NOT
>> emotional, it is just a help.
>
> Saying "Facepalm" is emotional and has nothing to do with the
> technical issues.

Facepalm is heavily used on Internet:
https://en.wikipedia.org/wiki/Facepalm#Internet_usage

it is how people including me react to disappointing. It is those
who only see facepalm make it irrelevant to the technical discussion
in this thread.

>
> You can keep showing us how expertly you can deflect the real
> issue we are discussion here, but that won't improve the situation
> at all I am afraid.

Of course, there are just too many people too lazy to do a google search:

https://lists.debian.org/debian-kernel/2013/05/msg00500.html


>
>> Not everyone is as free to travel to Canada without a visa as you,
>> unfortunately.
>
> We hold netdev in other countries all over the world, stop making
> excuses.

The only countries you hold netdev are Canada, Japan and Spain
(to my knowledge). If you check:

https://en.wikipedia.org/wiki/Visa_requirements_for_Chinese_citizens#Visa_requirements

It is very easy to find out if it is an excuse or a fact.
