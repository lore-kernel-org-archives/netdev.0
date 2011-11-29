From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Tue, 29 Nov 2011 23:15:09 +0100
Message-ID: <1322604909.2596.38.camel@edumazet-laptop>
References: <CAF9AA63.1622%ulrich.weber@sophos.com>
	 <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz>
	 <4ED4A399.6090709@sophos.com>
	 <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr>
	 <4ED550E7.1090609@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Ulrich Weber <ulrich.weber@sophos.com>,
	Amos Jeffries <squid3@treenet.co.nz>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39252 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab1K2WPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 17:15:15 -0500
In-Reply-To: <4ED550E7.1090609@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 22:38 +0100, Krzysztof Ol=C4=99dzki a =
=C3=A9crit :

> But without NAT you have pretty big chance to have the same IPv6=20
> *suffix* everywhere, based on you MAC address. In your Home, your Wor=
k,=20
> in a Cafe or in a hotel during your vacations in Portugal. So yes, NA=
T=20
> is not a perfect solution but it really helps you privacy.
>=20

Good point, but we can change MAC address (use a random one) on most
NIC, cant we ?
