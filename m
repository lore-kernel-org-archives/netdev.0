From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/14 v2] mac802154: allocation of ieee802154 device
Date: Wed, 28 Dec 2011 02:31:45 -0500 (EST)
Message-ID: <20111228.023145.2078199792492848729.davem@davemloft.net>
References: <1324919047-14851-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<20111226.150924.734645949941473044.davem@davemloft.net>
	<CAJmB2rAyyPmYTmtTvFK3UuFn9t+361raA5R=92XPNHrH7dfgfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab1L1Hbu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 02:31:50 -0500
In-Reply-To: <CAJmB2rAyyPmYTmtTvFK3UuFn9t+361raA5R=92XPNHrH7dfgfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Wed, 28 Dec 2011 10:19:23 +0300

> Dear David,
>=20
> 2011/12/26 David Miller <davem@davemloft.net>:
>> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
>> Date: Mon, 26 Dec 2011 20:04:07 +0300
>>
>>> + =A0 =A0 /*
>>> + =A0 =A0 =A0* SoftMAC device is registered and running. One can ad=
d
>>> + =A0 =A0 =A0* subinterfaces.
>>> + =A0 =A0 =A0*/
>>> + =A0 =A0 unsigned running:1;
>>
>> I told you to change this to a 'bool' in my previous review of your =
changes.
>>
>> I'm pretty much going to stop reviewing right here, because I don't
>> want to waste my time only to find out that you've ignored other
>> review feedback I've already given to you.
>>
>=20
> Regarding your comments to my previous post, none of them was omitted=
=2E I
> reworked code according to them and added extended comments in a patc=
h
> explaining why I can't follow your hint. The issue with 'bool' you ma=
rked
> was in another patch (#14) which I already fixed.

My bad, I thought I had asked you do it here too.

Sorry about that.
