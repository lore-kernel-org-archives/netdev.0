From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] bnx2x: Resolving a possible dead-lock
 situation
Date: Tue, 23 Nov 2010 17:55:42 +0100
Message-ID: <1290531342.3046.115.camel@edumazet-laptop>
References: <1290528912.15453.3.camel@lb-tlvb-vladz>
	 <1290529777.3046.99.camel@edumazet-laptop>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEF920549@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	netdev list <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61254 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab0KWQzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 11:55:48 -0500
Received: by wyb28 with SMTP id 28so8471110wyb.19
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 08:55:47 -0800 (PST)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEF920549@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 novembre 2010 =C3=A0 08:36 -0800, Vladislav Zolotarov a =C3=
=A9crit :
> >=20
> > That seems strange. Even if performance penalty is not minimal, it
> > should be avoided.
> >=20
> > If problem comes from ethtool, why not preventing BH in ethtool its=
elf
> > ?
>=20
> Looks good. Let me run a few checks before u submit a patch to Dave. =
Or do u prefer=20
> me to push it on your behalf?

I was only suggesting an alternate patch, I am not able to test it ;)



