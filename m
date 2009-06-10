From: Sven Anders <anders@anduras.de>
Subject: EP80579 (Tolapai) Ethernet adapter
Date: Wed, 10 Jun 2009 14:22:32 +0200
Message-ID: <4A2FA588.4020900@anduras.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:37671 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967AbZFJMuq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:50:46 -0400
Received: from popper.anduras.local (p549185D2.dip0.t-ipconnect.de [84.145.133.210])
	(Authenticated sender: anduras@anduras.priv)
	by metropolitan.anduras.de (Postfix) with ESMTP id 2B0BE1E544C
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 14:22:33 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by popper.anduras.local (Postfix) with ESMTP id 4D49A79B6
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 14:21:56 +0200 (CEST)
Received: from popper.anduras.local ([127.0.0.1])
	by localhost (popper.anduras.local [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 00324-02 for <netdev@vger.kernel.org>;
	Wed, 10 Jun 2009 14:21:56 +0200 (CEST)
Received: from [10.10.20.100] (applecar.anduras.local [10.10.20.100])
	by popper.anduras.local (Postfix) with ESMTP id 2F62379B3
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 14:21:56 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I want to use the ethernet adapter on my Intel Tolapai based
board. The machine has the EP80579 Integrated Processor
(aka Tolapai) on it.

I check the latest Linux kernel for support, but it is not
supported.

Then I checked the Intel website and found a development kit,
which has a driver, but the development kit requires the old
kernel 2.6.18 whereas I want to use the latest kernel.

Unfortunatly I have not found any email address in the sources
to make direct contact. That's why I'll ask my questions here.

1) Do anybody know about the development of an (newer) driver?
2) What's the best way to contact the Intel development crew?
3) Can I use any other existing driver (by adding simply the
   PCI IDs)?
4) Should I adapt the existing driver (from Intel) to the
   newer kernel and try to get it merged? The code is GPL, so
   this is no problem. Any experiences? As I stated before,
   I do lack any direct contact, so I'm not sure what's the
   best way to proceed?!

Maybe anybody can help me in this issue...

Regards
 Sven
--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campai=
gn
                                                 /\ Support plain text =
e-mail
 ANDURAS service solutions AG
 Innstra=DFe 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90=
 50-55

Rechtsform: Aktiengesellschaft - Sitz: Passau - Amtsgericht Passau HRB =
6032
Mitglieder des Vorstands: Sven Anders, Marcus Junker
Vorsitzender des Aufsichtsrats: Mark Peters

