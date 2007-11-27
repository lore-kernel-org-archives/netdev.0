From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: Re: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 05:07:27 -0800 (PST)
Message-ID: <677950.98010.qm@web51406.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51406.mail.re2.yahoo.com ([206.190.38.185]:24040 "HELO
	web51406.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755102AbXK0NH2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 08:07:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Great :-(. I went over the ChangeLogs for later kernel versions, but
couldn't find anything.

I'll try to come up with a working .config for the most current kernel
that works on my hardware and test again.

Do you have a pointer to the fix so that I could try to patch a 2.6.20
kernel?
=20
-- =20
Regards
=20
       Joerg

----- Urspr=FCngliche Mail ----
Von: Patrick McHardy <kaber@trash.net>
An: Joerg Pommnitz <pommnitz@yahoo.com>
CC: Jarek Poplawski <jarkao2@o2.pl>; netdev@vger.kernel.org
Gesendet: Dienstag, den 27. November 2007, 13:54:11 Uhr
Betreff: Re: AW: Does tc-prio really work as advertised?

Joerg Pommnitz wrote:
>  > It works fine here, I'm guessing that J=F6rg is using an old kerne=
l
>  > version that had a bug in prio classification without filters.
>=20
> This is 2.6.20.21, from 17-Oct-2007.=20


Yes, that version is broken. I think it was fixed in 2.6.22 or 2.6.23.






      Jetzt Mails schnell in einem Vorschaufenster =FCberfliegen. Dies =
und viel mehr bietet das neue Yahoo! Mail - www.yahoo.de/mail
