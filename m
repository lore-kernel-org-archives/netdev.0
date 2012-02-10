From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Fri, 10 Feb 2012 15:41:41 -0500 (EST)
Message-ID: <20120210.154141.932816326069250336.davem@davemloft.net>
References: <4F34C17D.6070805@profihost.ag>
	<1328857670.2436.11.camel@edumazet-laptop>
	<1328898328.5661.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.priebe@profihost.ag, gregkh@linuxfoundation.org,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab2BJUnA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 15:43:00 -0500
In-Reply-To: <1328898328.5661.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Feb 2012 19:25:28 +0100

> Le vendredi 10 f=E9vrier 2012 =E0 08:07 +0100, Eric Dumazet a =E9crit=
 :
>> Le vendredi 10 f=E9vrier 2012 =E0 08:04 +0100, Stefan Priebe - Profi=
host AG
>> a =E9crit :
>> > Hi,
>> >=20
>> > Am 09.02.2012 23:13, schrieb David Miller:
>> > > From: David Miller <davem@davemloft.net>
>> > > Date: Wed, 08 Feb 2012 20:26:51 -0500 (EST)
>> > >=20
>> > >> I'll work on coming up with something much more sensible tonigh=
t.
>> > >=20
>> > > Ok, here's what I'm testing right now, please review and test.
>> >=20
>> > thanks for doing this work! I can't test asap as i can't do udpate=
s just
>> > for fun. I had the "luck" that last time there was the security bu=
g
>> > recarding /proc/mem so i was  able to schedule it pretty fast.
>> >=20
>> > At least the patch applies fine ;-)
>> >=20
>>=20
>> I'll do some build/run tests today, please Greg wait a bit before
>> applying this combo patch.
>>=20
>=20
> Tests done and no problem met.

Thanks for testing Eric, I'll formally submit this to Greg right now.
