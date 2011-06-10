From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 20:04:14 +0200
Message-ID: <1307729054.2872.0.camel@edumazet-laptop>
References: <4DF0E638.2010506@uth.tmc.edu>
	 <1307714177.4044.4.camel@edumazet-laptop> <4DF233CE.5020000@uth.tmc.edu>
	 <4DF24154.3060505@uth.tmc.edu> <1307722621.4044.17.camel@edumazet-laptop>
	 <4DF248C5.9050004@uth.tmc.edu> <1307724870.4044.20.camel@edumazet-laptop>
	 <4DF25BA2.4040200@uth.tmc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51342 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757515Ab1FJSES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 14:04:18 -0400
Received: by wya21 with SMTP id 21so2044259wya.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 11:04:17 -0700 (PDT)
In-Reply-To: <4DF25BA2.4040200@uth.tmc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 juin 2011 =C3=A0 13:00 -0500, Charles Bearden a =C3=A9cr=
it :

> Each keepalive from the Win2008 machine has a 1-byte payload 0x00. Th=
e last byte=20
> of the last packet with a payload before that from the Win2008 host (=
at=20
> 14:40:18.166394 in the paste) is also 0x00. Is that what you were ask=
ing about?
>=20

Yes, thats fine, thanks :)


