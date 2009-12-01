From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sk_nulls_next_rcu
Date: Tue, 01 Dec 2009 04:54:42 +0100
Message-ID: <4B149382.9030009@gmail.com>
References: <200912010219.29340.opurdila@ixiacom.com> <20091130.162454.119309341.davem@davemloft.net> <200912010232.47308.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38774 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbZLADyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 22:54:45 -0500
In-Reply-To: <200912010232.47308.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Tuesday 01 December 2009 02:24:54 you wrote:
>> From: Octavian Purdila <opurdila@ixiacom.com>
>> Date: Tue, 1 Dec 2009 02:19:29 +0200
>>
>>> I am trying to convert the LLC code to RCU, and it appears that for=
 proc
>>> support a sk_nulls_next_rcu would be required.
>>>
>>> Is this the wrong way to do it, or is it that nobody need it yet?
>> I think simply nobody needed it yet.
>>
>> Eric, please take a look at Octavian's patch, thanks!
>>
>=20
> I will send a patch series later with several LLC enhancements, no ne=
ed to=20
> look over the LLC bits yet - its not all done yet. I'll CC Eric on th=
e RCU=20
> parts :)

No problem I'll review your patches

Thanks

