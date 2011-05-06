From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter/IPv6: initialize TOS field in REJECT target
 module
Date: Fri, 06 May 2011 12:38:37 +0200
Message-ID: <4DC3CFAD.8020305@netfilter.org>
References: <1303461461.3134.15.camel@edumazet-laptop>	 <4DB61C2C.7060508@netfilter.org> <1303781180.2874.13.camel@nausicaa>	 <20110425.221744.226775617.davem@davemloft.net>	 <1303795522.6010.5.camel@nausicaa>  <4DB6E607.6000303@netfilter.org> <1304670430.6581.45.camel@nexus.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jengelh@medozas.de,
	Patrick McHardy <kaber@trash.net>
To: =?UTF-8?B?RmVybmFuZG8gTHVpcyBWw6F6cXVleiBDYW8=?=
	<fernando@oss.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37747 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075Ab1EFKim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2011 06:38:42 -0400
In-Reply-To: <1304670430.6581.45.camel@nexus.oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/11 10:27, Fernando Luis V=C3=A1zquez Cao wrote:
> On Tue, 2011-04-26 at 17:34 +0200, Pablo Neira Ayuso wrote:
>> On 26/04/11 07:25, Fernando Luis Vazquez Cao wrote:
>>> Pablo, could you pull in the two patches below? They have already b=
een
>>> acked by Eric. It would be great it we could get them merged for th=
e
>>> next -rc and stable releases.
>>>
>>> [PATCH] netfilter/IPv6: fix DSCP mangle code
>>> [PATCH] netfilter/IPv6: initialize TOS field in REJECT target modul=
e
>>
>> Patrick is the primary link to take patches, I'm including him in th=
is
>> CC. If he experiences any problem, I'll make sure that these hit -rc=
, so
>> never mind.
>=20
> It seems that the two patches above did not make it into 2.6.39-rc6. =
Any
> chance we can get them merged before 2.6.39 is released?

I'll pick them and push them to davem by monday. Thanks!
