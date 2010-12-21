From: "Richard Scheffenegger" <realarms@gmx.at>
Subject: Linux SACK - lost retransmission detection
Date: Tue, 21 Dec 2010 11:42:52 +0100
Message-ID: <20101221104252.36840@gmx.net>
References: <20101221103539.137960@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:51145 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751058Ab0LUKm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 05:42:57 -0500
In-Reply-To: <20101221103539.137960@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

One more, generic, question:

I found that Linux added SACK with kernel version 2.1.91, but I wasn=E2=
=80=99t able to track down when lost retransmission detection (LRD) was=
 added. The only research paper I found which appears to describe appro=
ximately what linux does is from an Korean researcher, who claims to ha=
ve not contributed any code to the linux kernel. Do you happen to have =
more pointers?

I=E2=80=99m currently looking into ways of how to make lost retransmiss=
ions detection work also at end-of-stream (alleviating RTOs even with s=
mall windows at least partially).

Best regards,
   Richard
--=20
Neu: GMX De-Mail - Einfach wie E-Mail, sicher wie ein Brief! =20
Jetzt De-Mail-Adresse reservieren: http://portal.gmx.net/de/go/demail
