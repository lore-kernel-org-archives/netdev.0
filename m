From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: IPsec with aes-cbc and geode-aes driver completely freezes 2.6.20.1
Date: Thu, 15 Mar 2007 06:45:33 -0700 (PDT)
Message-ID: <20070315134533.21402.qmail@web51408.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: info-linux@geode.amd.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51408.mail.re2.yahoo.com ([206.190.38.187]:41071 "HELO
	web51408.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1161344AbXCONwN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 09:52:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,
the subject line basically says it all. I was trying to offload IPsec e=
ncryption to the hardware encryption engine on my Geode LX800. The exac=
t same setkey command works fine with software aes.

In case it matters: this is with a MSEP800/A board from DIGITAL-LOGIC A=
G (see http://www.digitallogic.com/english/products/catalog07/epic_deta=
il.asp?id=3DMSEP800_L).

Did anybody ever succeed with Geode hardware accelerated IPsec? Did you=
 have to do anything special?
=20
--=20

Regards

       Joerg








=09
	=09
___________________________________________________________=20
Der fr=FChe Vogel f=E4ngt den Wurm. Hier gelangen Sie zum neuen Yahoo! =
Mail: http://mail.yahoo.de
