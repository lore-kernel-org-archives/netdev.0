From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 17:04:13 +0100
Message-ID: <1300550653.2831.34.camel@edumazet-laptop>
References: <4D84A46B.1000407@example.com>
	 <AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>
	 <1300547930.2831.27.camel@edumazet-laptop>
	 <201103191631.07952.oliver@neukum.org>
	 <1300548821.2831.28.camel@edumazet-laptop>
	 <1300549151.2831.32.camel@edumazet-laptop>  <4D84D098.1050802@example.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	Anca Emanuel <anca.emanuel@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: piotr@hosowicz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45345 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906Ab1CSQEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 12:04:20 -0400
In-Reply-To: <4D84D098.1050802@example.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 19 mars 2011 =C3=A0 16:49 +0100, Piotr Hosowicz a =C3=A9crit =
:

> I do not understand. I reverted the commit you mentioned and am build=
ing=20
> now. Will it suffice?
>=20

Either you

1) Revert the commit

OR

2) apply my patch


;)


