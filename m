From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the
 passive open side
Date: Wed, 08 Jun 2011 16:44:33 -0700 (PDT)
Message-ID: <20110608.164433.1248144748353908346.davem@davemloft.net>
References: <BANLkTikpmXMpuTmgejsgisV9O2fP1i7VLnUO3bcYLSU0+iXJVg@mail.gmail.com>
	<BANLkTimo_fbezdX2evKt0pAg0N+DSJQeSR6NoHLus=Z40WLkHg@mail.gmail.com>
	<1307576361.3980.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hkchu@google.com, hagen@jauu.net, tsunanet@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab1FHXop convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 19:44:45 -0400
In-Reply-To: <1307576361.3980.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jun 2011 01:39:21 +0200

> Le mercredi 08 juin 2011 =E0 15:26 -0700, Jerry Chu a =E9crit :
>> It just occurred to me now that initRTO is being reduced, both TCP_S=
YN_RETRIES
>> and TCP_SYNACK_RETRIES should be bumped up a bit, to e.g., 7 (?) to =
meet the
>> 3 minutes R2 requirement per RFC1122.
>>=20
>> If you agree, I will submit another patch.
>=20
> Good catch, but no RFC lowered yet this 3 minutes requirement ?

I host my email on other planets, please do not break this.
