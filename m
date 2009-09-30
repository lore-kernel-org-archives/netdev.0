From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] bonding: send ARP requests on interfaces other than
 the primary for tlb/alb
Date: Wed, 30 Sep 2009 09:49:37 +0200
Message-ID: <4AC30D91.9070507@gmail.com>
References: <1254269731-7341-3-git-send-email-fubar@us.ibm.com>	<1254269731-7341-4-git-send-email-fubar@us.ibm.com>	<4AC2EA97.5010809@gmail.com> <20090930.002721.160750704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58861 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbZI3Hty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 03:49:54 -0400
In-Reply-To: <20090930.002721.160750704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Sep 2009 07:20:23 +0200
>=20
>> Jay Vosburgh a =E9crit :
>>> -		/* The ARP relpy packets must be delayed so that
>>> -		 * they can cancel out the influence of the ARP request.
>>> -		 */
>> COmments should have the following form :
>> /*
>>  * This is a fine comment
>>  */
>=20
> I definitely prefer what is used in the patch, whereas your suggestio=
n
> wastes a precious line on the screen and doesn't look markedly better
> at all.
>=20
> Look at any TCP protocol source file and you'll see the consistent
> application of:
>=20
> 	/* This form of
> 	 * comment.
> 	 */
>=20
> there.

No problem David, I dont want to waste time to discuss this kind of stu=
ff,
but you know my own opinion, and I know yours as well !

As a non native, some things that are painful details for you definitly=
 help
my brain to decode English sentences. Uppercase on first letter, final =
point,
spelling, ...

