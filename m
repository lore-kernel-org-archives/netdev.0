From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Tue, 08 Jan 2013 11:20:20 +0800
Message-ID: <50EB9074.3090100@asianux.com>
References: <50E82D7D.4090107@asianux.com>  <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>  <1357528746.4940.31.camel@joe-AO722> <1357534195.21481.31.camel@joe-AO722>  (sfid-20130107_055017_668200_9F1C3EAF) <1357544828.9912.0.camel@jlt4.sipsolutions.net>  <1357579362.21481.45.camel@joe-AO722> <50EB8B1A.9000404@asianux.com> <1357614687.12749.41.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	stas.yakovlev@gmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:24586 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab3AHDT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:19:27 -0500
In-Reply-To: <1357614687.12749.41.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B401=E6=9C=8808=E6=97=A5 11:11, Joe Perches =E5=86=
=99=E9=81=93:
> On Tue, 2013-01-08 at 10:57 +0800, Chen Gang wrote:
>>   sorry, I am not quite clear about what you said.
>=20
> You found some overrun errors and proposed a patch.
> Your solution could output incomplete SSIDs.
>=20
> I proposed a different patch that would fully output
> any binary/non-ascii printable SSID.
>=20
> I also proposed a different mechanism to avoid the
> overrun via printk and also avoid possibly excessive
> stack consumption as a means for John Linville to
> select 1 of the above options.
>=20
> I don't care what is done with any of those proposed
> patches.
>=20
> Clear?
>=20

  ok

--=20
Chen Gang

Asianux Corporation
