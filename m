From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] netem: add ECN capability
Date: Tue, 1 May 2012 11:49:51 -0700
Message-ID: <CAA93jw7r8UTTEy9KjmQekbuJ6U7hVVURtr0z9pw9L8wa67BUZA@mail.gmail.com>
References: <1335863465.11396.45.camel@edumazet-glaptop>
	<20120501.094051.655617860554790911.davem@davemloft.net>
	<20120501095938.7214e4a5@s6510.linuxnetplumber.net>
	<20120501.131750.636505003036346376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	hagen@jauu.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:61434 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab2EAStx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 14:49:53 -0400
Received: by wibhj6 with SMTP id hj6so3962974wib.1
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 11:49:51 -0700 (PDT)
In-Reply-To: <20120501.131750.636505003036346376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 1, 2012 at 10:17 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 1 May 2012 09:59:38 -0700
>
>> On Tue, 01 May 2012 09:40:51 -0400 (EDT)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Tue, 01 May 2012 11:11:05 +0200
>>>
>>> > From: Eric Dumazet <edumazet@google.com>
>>> >
>>> > Add ECN (Explicit Congestion Notification) marking capability to =
netem
>>> >
>>> > tc qdisc add dev eth0 root netem drop 0.5 ecn
>>> >
>>> > Instead of dropping packets, try to ECN mark them.
>>> >
>>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>>>
>>> Applied.
>>
>> At least give a day of review, rather than premature acceptance
>
> Yeah, because Eric Dumazet is going to fall off the face of the
> planet and not fix whatever problems you have with his work.
>
> Get real Stephen.

I'd be more concerned about wayward buses, or a team of elite
ninja's hired by outraged BSD and windows hackers sent to slow
eric down.

As I think about it, I think he could handle the ninja problem, tho.



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
