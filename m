From: Diego Elio =?ISO-8859-1?Q?Petten=F2?= <flameeyes@gmail.com>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 2)
Date: Fri, 03 Sep 2010 14:39:24 +0200
Message-ID: <1283517564.8231.0.camel@yamato.local>
References: <1283476464-14341-1-git-send-email-flameeyes@gmail.com>
	 <1283496928.3699.1581.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60332 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab0ICMjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 08:39:23 -0400
Received: by fxm13 with SMTP id 13so1024068fxm.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 05:39:22 -0700 (PDT)
In-Reply-To: <1283496928.3699.1581.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il giorno ven, 03/09/2010 alle 08.55 +0200, Eric Dumazet ha scritto:
>=20
>=20
> why use an 'unsigned long', since user pointer is a 'int *' ?=20

I really just picked up the basic SIOCINQ from UDP/RDP

--=20
Diego Elio Petten=C3=B2 =E2=80=94 =E2=80=9CFlameeyes=E2=80=9D
http://blog.flameeyes.eu/

If you found a .asc file in this mail and know not what it is,
it's a GnuPG digital signature: http://www.gnupg.org/


