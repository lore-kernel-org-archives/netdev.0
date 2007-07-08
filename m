From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.23] Per-datagram TTL and TOS via sendmsg()
Date: Sat, 07 Jul 2007 22:58:08 -0700 (PDT)
Message-ID: <20070707.225808.51855943.davem@davemloft.net>
References: <200707071421.44131@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: rdenis@simphalempin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751784AbXGHF5q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2007 01:57:46 -0400
In-Reply-To: <200707071421.44131@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: R=E9mi_Denis-Courmont <rdenis@simphalempin.com>
Date: Sat, 7 Jul 2007 14:21:43 +0300

> This patch adds support for specifying IPv4 Time-To-Live (IP_TTL) and=
/or=20
> Type-Of-Service (IP_TOS) values on a per datagram basis through=20
> sendmsg() ancilliary data. Until then, it only worked for IPv6 socket=
s=20
> (using IPV6_HOPLIMIT and IPV6_TCLASS).
>=20
> Signed-off-by: R=E9mi Denis-Courmont <rdenis@simphalempin.com>

Your email client corrupted your patch by adding newline breaks
all over the place, please correct this and make a full
resubmission.  Resubmit the full changelog and patch,
don't just reply to this email with the patch as that screws
up how I integrate people's work, thanks :)
