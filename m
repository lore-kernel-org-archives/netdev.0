From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] Doc: Fix spelling in RCU/rculist_nulls.txt.
Date: Mon, 30 Mar 2009 22:10:25 +0200
Message-ID: <49D12731.8000904@cosmosbay.com>
References: <20090330085302.19172.22808.stgit@localhost.localdomain> <20090330090306.19172.94170.stgit@localhost.localdomain> <49D0FA6E.4090402@gmail.com> <Pine.LNX.4.64.0903302155550.13385@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52049 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928AbZC3UKf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 16:10:35 -0400
In-Reply-To: <Pine.LNX.4.64.0903302155550.13385@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer a =E9crit :
> On Mon, 30 Mar 2009, Jarek Poplawski wrote:
>=20
>> Jesper Dangaard Brouer wrote, On 03/30/2009 11:03 AM:
>>
>>> Trival spelling fixes in RCU/rculist_nulls.txt.
>>>
>>>  the lookup met the end of chain. If final 'nulls' value
>>>  is not the slot number, then we must restart the lookup at
>>> -the begining. If the object was moved to same chain,
>>> +the beginning. If the object was moved to same chain,
>>
>>
>> "by way":)
>> +the beginning. If the object was moved to the same chain,
>=20
> *LOL* this was suppose to be a simple trivial insignificant fix, but =
you
> are right there is _also_ missing a "the" in the sentence ;-).
>=20


RCU is complex, and english too, at last for me ...

I am very surprised you found so few errors in this file, that mixes th=
ese two parts :)


