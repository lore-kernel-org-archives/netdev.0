From: "Rick Koshi" <netdev@more-right-rudder.com>
Subject: Re: Multiple GRE tunnels on the same host, only one routes incoming packets
Date: Sat, 11 Feb 2012 06:18:58 -0500
Message-ID: <201202111118.q1BBIwSU020099@hope.more-right-rudder.com>
References: <201202111040.q1BAeESi014636@hope.more-right-rudder.com> <318741328957992@web13.yandex.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm14-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.15]:27791
	"HELO nm14-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753199Ab2BKLZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 06:25:18 -0500
In-reply-to: <318741328957992@web13.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"\"Oleg A. Arkhangelsky\"" writes:
>=20
>=20
> 11.02.2012, 14:40, "Rick Koshi" <netdev@more-right-rudder.com>:
>=20
> > Is this "working as designed?" =9AWhat I'd like to have happen,
> > of course, is for all packets on both tunnels to be properly
> > forwarded. =9AIs this possible?
>=20
> Maybe you should try the "key" param to ip tunnel command?

Thank you for the suggestion.  I tried adding key params
to the tunnel setup commands, but it had no effect.  The
behavior is identical.

    -- Rick
