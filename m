From: Lionel Landwerlin <landwer@free.fr>
Subject: Re: sky2 or acpi problem ?
Date: Thu, 01 Feb 2007 19:35:32 +0100
Message-ID: <1170354932.6698.4.camel@cocoduo>
References: <1170352795.5299.17.camel@cocoduo>
	 <45C22F57.3030804@conceptonline.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Fagyal Csongor <concept@conceptonline.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:39467 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422926AbXBASfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 13:35:36 -0500
In-Reply-To: <45C22F57.3030804@conceptonline.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 01 f=C3=A9vrier 2007 =C3=A0 19:20 +0100, Fagyal Csongor a =C3=A9=
crit :
> Lionel Landwerlin wrote:

> I have idle=3Dpoll now, according to this thread:
>=20
> http://www.gossamer-threads.com/lists/linux/kernel/725399
>=20
>=20
> No lockup so far, but I only have this setting since yesterday...
>=20

I tried idle=3Dpoll too, same effect than disable_msi=3D1, tested a cou=
ple
of hours only, maybe this leads to crash too. But anyway this is simply
unusable on a laptop (macbook), fan is running almost at full speed...


--=20
Lionel Landwerlin <landwer@free.fr>

