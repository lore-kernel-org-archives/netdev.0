From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [netfilter / iptables] question
Date: Thu, 1 Apr 2010 20:35:59 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004012035490.8633@obet.zrqbmnf.qr>
References: <v2if4f837ab1004010944yd08c37c5u23d6f2d07df7ccc6@mail.gmail.com>  <alpine.LSU.2.01.1004011857440.788@obet.zrqbmnf.qr> <n2if4f837ab1004011011gf3d82d3fzfd1423a812f98520@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:37477 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755333Ab0DASgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 14:36:03 -0400
In-Reply-To: <n2if4f837ab1004011011gf3d82d3fzfd1423a812f98520@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2010-04-01 19:11, thomas yang wrote:

>2010/4/2 Jan Engelhardt <jengelh@medozas.de>:
>> On Thursday 2010-04-01 18:44, thomas yang wrote:
>>
>>>Hi,
>>>
>>>I want to copy/ clone a =C2=A0sk_buff =C2=A0*skb =C2=A0to =C2=A0*skb=
2 =C2=A0on my Linux router,
>>> =C2=A0then transmit both =C2=A0skb2 =C2=A0 and =C2=A0skb =C2=A0.
>>>
>>>How to do this with =C2=A0 netfilter hook function =C2=A0/ iptables =
=C2=A0?
>>>
>> Wait for xt_TEE to be merged.
>>
>
>I want to route skb to 'path 1' , route the copied/cloned skb2 to
>'path 2'    simultaneously,
>if one of them lose , it will not be a problem.
>
>What's the function of xt_TEE ?

=46ollow the mailing list.
http://marc.info/?t=3D127003152600006&r=3D1&w=3D2
