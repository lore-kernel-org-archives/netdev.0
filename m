From: Diego Elio =?ISO-8859-1?Q?Petten=F2?= <flameeyes@gmail.com>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 3)
Date: Fri, 01 Oct 2010 11:35:48 +0200
Message-ID: <1285925748.6591.569.camel@yamato.local>
References: <1285725095-9860-1-git-send-email-flameeyes@gmail.com>
	 <20100930.173557.108787840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43762 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab0JAJgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 05:36:01 -0400
In-Reply-To: <20100930.173557.108787840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il giorno gio, 30/09/2010 alle 17.35 -0700, David Miller ha scritto:
>=20
>=20
> Please put the break statement inside of the basic block.
>=20
> The way you have it here the indentation looks not so nice.=20

Okay will resend; please do note that I copied the style (and most of
the code) from dccp anyway.

--=20
Diego Elio Petten=C3=B2 =E2=80=94 =E2=80=9CFlameeyes=E2=80=9D
http://blog.flameeyes.eu/

If you found a .asc file in this mail and know not what it is,
it's a GnuPG digital signature: http://www.gnupg.org/


