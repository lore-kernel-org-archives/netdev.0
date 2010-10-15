From: Diego Elio =?ISO-8859-1?Q?Petten=F2?= <flameeyes@gmail.com>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 3 bis)
Date: Fri, 15 Oct 2010 19:08:55 +0200
Message-ID: <1287162535.465.33.camel@yamato.local>
References: <20100930.173557.108787840.davem@davemloft.net>
	 <1285926965-5130-1-git-send-email-flameeyes@gmail.com>
	 <1287152557.465.24.camel@yamato.local>
	 <20101015.095940.39172218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58355 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756538Ab0JORJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 13:09:48 -0400
In-Reply-To: <20101015.095940.39172218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il giorno ven, 15/10/2010 alle 09.59 -0700, David Miller ha scritto:
>=20
> I'm pretty sure it's in the net-next-2.6, is it not?=20

Ah yes it is, sorry, I was mislead by the presence in -rc8 of the other
SCTP patches that came afterwards (and because it has been since August
I'm dragging this patch around).

Thank you very much!

--=20
Diego Elio Petten=C3=B2 =E2=80=94 =E2=80=9CFlameeyes=E2=80=9D
http://blog.flameeyes.eu/

If you found a .asc file in this mail and know not what it is,
it's a GnuPG digital signature: http://www.gnupg.org/


