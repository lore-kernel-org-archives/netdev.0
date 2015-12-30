From: David Miller <davem@davemloft.net>
Subject: Re: Q: bad routing table cache entries
Date: Wed, 30 Dec 2015 12:56:37 -0500 (EST)
Message-ID: <20151230.125637.569638256496381680.davem@davemloft.net>
References: <20151229152208.GA22423@oracle.com>
	<5683D131.4090703@list.ru>
	<1451485062.8255.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stsp@list.ru, sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbL3R4j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:56:39 -0500
In-Reply-To: <1451485062.8255.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Dec 2015 09:17:42 -0500

> On Wed, 2015-12-30 at 15:42 +0300, Stas Sergeev wrote:
>> 29.12.2015 18:22, Sowmini Varadhan =D0=C9=DB=C5=D4:
>> > Do you have admin control over the ubuntu router?
>> > If yes, you might want to check the shared_media [#] setting=20
>> > on that router for the interfaces with overlapping subnets.
>> > (it is on by default, I would try turning it off).
>> That didn't help, problem re-appears.
>> Thanks anyway, looks like I am going to disable accept_redirects the=
n.
>> It seems buggy and obviously no one cares.
>=20
> Obviously some people take vacations at this period of the year, and =
do
> stay away from netdev traffic.

+1
