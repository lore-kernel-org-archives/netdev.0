From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168 hangs when sending data at full speed on a gigabit
 link
Date: Sun, 1 Sep 2013 23:36:10 +0200
Message-ID: <20130901213610.GA25211@electric-eye.fr.zoreil.com>
References: <5221C226.9040209@starox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: =?utf-8?B?RnLDqWTDqXJpYw==?= Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37454 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170Ab3IAVgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Sep 2013 17:36:19 -0400
Content-Disposition: inline
In-Reply-To: <5221C226.9040209@starox.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46r=C3=A9d=C3=A9ric Leroy <fredo@starox.org> :
[...]
> For triggering the bug, I use iperf, which either works, or hangs alm=
ost
> immediately
> with multiple threads :
>=20
>         iperf -c myiperfserver -P 3 -t 60
>=20
> Could you help me to fix this ?

Does it behave the same if you don't load the vbox modules at all ?

--=20
Ueimor
