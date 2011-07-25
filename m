From: Sven Anders <anders@anduras.de>
Subject: Realtek 8139 Flow Control?
Date: Mon, 25 Jul 2011 21:42:08 +0200
Message-ID: <4E2DC710.5000100@anduras.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090705060909090300090202"
Cc: becker@scyld.com, jgarzik@pobox.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailr01.anduras.de ([89.28.138.12]:46281 "EHLO
	mailr01.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab1GYTwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 15:52:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090705060909090300090202
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hello!

I have just a short question.

We have appliances with Realtek 8139C/8139C+ (rev 10) chipsets (with the
PCI IDs: 10ec:8139). We are using the 8139too driver (version: 0.9.28)
According the datasheet the chipset supports Flow Control (IEEE 802.3x).


I want to know, if the support for enabling flow control is missing in
the driver by purpose or is only not implemented due to missing time?


Regards
 Sven

--=20
 Sven Anders <anders@anduras.de>                 () UTF-8 Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS intranet security AG
 Messestra=DFe 3 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Rechtsform: Aktiengesellschaft - Sitz: Passau - Amtsgericht: Passau HRB 6=
032
Mitglieder des Vorstands: Dipl.-Inf. Sven Anders, Dipl.-Inf. Marcus Junke=
r
Vorsitzender des Aufsichtsrats: RA Mark Peters

--------------090705060909090300090202
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="anders.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
org:ANDURAS AG;Research and Development
adr;quoted-printable:;;Messestra=C3=9Fe 3;Passau;Bavaria;94036;Germany
email;internet:anders@anduras.de
title:Dipl. Inf.
tel;work:++49 (0)851 / 490 50 -0
tel;fax:++49 (0)851 / 590 50 - 55
x-mozilla-html:FALSE
url:http://www.anduras.de
version:2.1
end:vcard


--------------090705060909090300090202--
