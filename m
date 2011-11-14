From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: Re: [PATCH RESUBMIT2 net-next 1/2] IPv6 routing, NLM_F_* flag
 support: warn if NEWROUTE lacks of both CREATE and REPLACE flags
Date: Mon, 14 Nov 2011 11:37:54 +0200
Message-ID: <1321263474.1858.8.camel@hakki>
References: <1321254611.23935.15.camel@hakki>
	 <20111114.020617.136865443034405914.davem@davemloft.net>
	 <1321259480.23935.75.camel@hakki>
	 <20111114.033608.2000639077648429389.davem@davemloft.net>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ext David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:13335 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab1KNJ0W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 04:26:22 -0500
In-Reply-To: <20111114.033608.2000639077648429389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-14 at 03:36 -0500, ext David Miller wrote:
> From: Matti Vaittinen <matti.vaittinen@nsn.com>
> Date: Mon, 14 Nov 2011 10:31:20 +0200
>=20
> > Messages can be changed, that's no problem. I would like to hear su=
ggestions=20
> > because I personally see not much problems in current messages.=20
>=20
> You don't even say that the route request is for an ipv6 route.

I'll add the IPv6 in prints, and also look through the =C5=95est of the=
 prints=20
in 2/2 patch && see if I can think of something to improve.

Also, this patch (1/2) has wrong subject and explanation - total brainf=
art
from my side, sorry. The check for NLM_F_REPLACE is not in this, but in=
=20
the 2/2 patch. I'll correct subject and explanation too.

--=20
Matti Vaittinen
+358 504863070
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Told a UDP joke the other night...
=2E..but I'm not sure everyone got it...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
