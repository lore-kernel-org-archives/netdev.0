From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: Bypass flow control problems
Date: Wed, 29 Dec 2010 10:49:09 +0200
Message-ID: <20101229084909.GS2754@reaktio.net>
References: <1293040291.1777.36.camel@alkis> <20101227134346.GD2754@reaktio.net> <1293612435.1813.9.camel@alkis>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alkis Georgopoulos <alkisg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:41222 "EHLO smtp.tele.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508Ab0L2ItL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 03:49:11 -0500
Content-Disposition: inline
In-Reply-To: <1293612435.1813.9.camel@alkis>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 29, 2010 at 10:47:15AM +0200, Alkis Georgopoulos wrote:
> ???????? 27-12-2010, ?????????? ??????, ?????? ?????? 15:43 +0200, ??=
/?? Pasi K=E4rkk=E4inen
> ????????????:
> > You could set up QoS rules on the server to limit the network speed=
 per client..
>=20
> That sounds promising. I'll try to limit the rate of packages that th=
e
> server sends to each client to 90 Mbps and see if that works around t=
he
> flow control problem. Any tips for a good method to do that?
>=20

I guess you need to read the Linux Advanced Routing and Traffic Control=
 howto..
it has examples how to use the Linux QoS stuff.

There are also some scripts out there that make it easier to set it up.

-- Pasi

