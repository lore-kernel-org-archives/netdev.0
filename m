From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: Receiving decrypted IPsec Packets including MAC source address
Date: Mon, 22 Sep 2008 01:25:11 -0700 (PDT)
Message-ID: <769319.35656.qm@web51402.mail.re2.yahoo.com>
Reply-To: pommnitz@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51402.mail.re2.yahoo.com ([206.190.38.181]:42851 "HELO
	web51402.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751886AbYIVIbx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 04:31:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
is there a way to get the source MAC address for a decrypted IPsec prot=
ected=20
UDP packet? For unencrypted data I would use RAW sockets, but this obvi=
ously=20
fails for encrypted data.

--=20
Regards
       Joerg

__________________________________________________
Do You Yahoo!?
Sie sind Spam leid? Yahoo! Mail verf=FCgt =FCber einen herausragenden S=
chutz gegen Massenmails.=20
http://mail.yahoo.com=20
