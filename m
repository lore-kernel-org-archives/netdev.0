From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter/IPv6: initialize TOS field in REJECT target
 module
Date: Tue, 26 Apr 2011 17:34:31 +0200
Message-ID: <4DB6E607.6000303@netfilter.org>
References: <1303461461.3134.15.camel@edumazet-laptop>	 <4DB61C2C.7060508@netfilter.org> <1303781180.2874.13.camel@nausicaa>	 <20110425.221744.226775617.davem@davemloft.net> <1303795522.6010.5.camel@nausicaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jengelh@medozas.de,
	Patrick McHardy <kaber@trash.net>
To: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1303795522.6010.5.camel@nausicaa>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/04/11 07:25, Fernando Luis Vazquez Cao wrote:
> On Mon, 2011-04-25 at 22:17 -0700, David Miller wrote:
>> From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
>> Date: Tue, 26 Apr 2011 10:26:20 +0900
>>
>>> On Tue, 2011-04-26 at 03:13 +0200, Pablo Neira Ayuso wrote:
>>>> On 22/04/11 10:37, Eric Dumazet wrote:
>>>>> Le vendredi 22 avril 2011 =C3=A0 17:11 +0900, Fernando Luis Vazqu=
ez Cao a
>>>>> =C3=A9crit :
>>>>>
>>>>>> Thank you!
>>>>>>
>>>>>> Should we send these two patches to -stable too?
>>>>>
>>>>> David takes care of stable submissions for netdev stuff, thanks.
>>>>
>>>> If the patch follows the netfilter path, we'll take care of sendin=
g
>>>> stable submissions.
>>>
>>> David, will you take care of these two patches or should they go th=
rough
>>> the netfilter tree?
>>
>> Netfilter, as usual.
>=20
> Thank you for the clarification. I really appreciate it.
>=20
> Pablo, could you pull in the two patches below? They have already bee=
n
> acked by Eric. It would be great it we could get them merged for the
> next -rc and stable releases.
>=20
> [PATCH] netfilter/IPv6: fix DSCP mangle code
> [PATCH] netfilter/IPv6: initialize TOS field in REJECT target module

Patrick is the primary link to take patches, I'm including him in this
CC. If he experiences any problem, I'll make sure that these hit -rc, s=
o
never mind.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
