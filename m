From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: kernel 2.6.23.8: KERNEL: assertion in net/ipv4/tcp_input.c
Date: Mon, 3 Dec 2007 01:00:26 +0100
Message-ID: <200712030100.26283.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:39413 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753994AbXLCAA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 19:00:28 -0500
Received: from eumel.h3.stusta.mhn.de (r081065.stusta.swh.mhn.de [10.150.81.65])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 1D70458003
	for <netdev@vger.kernel.org>; Mon,  3 Dec 2007 01:00:27 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

with kernel 2.6.23.8 we saw a

KERNEL: assertion ((int)tcp_packets_in_flight(tp) >=3D 0) failed at=20
net/ipv4/tcp_input.c (1292)

Regards,

Wolfgang Walter
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
