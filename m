From: Ben Greear <greearb@candelatech.com>
Subject: Re: A pure virtual nic
Date: Fri, 30 Dec 2011 07:44:21 -0800
Message-ID: <4EFDDC55.80406@candelatech.com>
References: <CAEk7JKbQgjiL90oGyWy6jkwY7eudUUqLP7GvdjfMcotTN8YhwQ@mail.gmail.com> <CAHXqBFKstJCQ4rif6S7mNuQUzFjJ1wfRKAksFePJyBoTw0YTfg@mail.gmail.com> <CAEk7JKY6xtBm4DraqRMYEnmZZhsOZoZG-MSgrq+W4n2eCCz1Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>
To: "Li, Zhen-Hua" <lizhenhua.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56766 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1L3PoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 10:44:24 -0500
In-Reply-To: <CAEk7JKY6xtBm4DraqRMYEnmZZhsOZoZG-MSgrq+W4n2eCCz1Sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/29/2011 05:51 PM, Li, Zhen-Hua wrote:
> I plan to add some protocols to it. For example, HTTP Proxy packet
> analysis. So user-space programs can use an NIC in common way in a
> proxy needed environment.

When a program transmits a packet on your virtual NIC, where does the
packet go?  When it receives a packet, where did the packet come from?

Thanks,
Ben

>
>
>
> 2011/12/29 Micha=C5=82 Miros=C5=82aw<mirqus@gmail.com>:
>> 2011/12/29 Zhen-Hua Li<lizhenhua.dev@gmail.com>:
>>> I have opened a project in SourceForge, it provides a pure virtual
>>> ethernet adapter.  If you are interested to join it, please mail me=
=2E
>>
>> Is veth or tap (both in vanilla kernel) not enough for you? What are
>> the differences?
>>
>> Best Regards,
>> Micha=C5=82 Miros=C5=82aw
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
