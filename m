From: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Subject: Re: TCP fast retransmit
Date: Fri, 9 Dec 2011 17:17:50 +0100
Message-ID: <6DA1FA31-8983-4338-A1B8-5697A876E2B6@mpi-bpc.mpg.de>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
 <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <C2C333F1-98FD-41FB-9CFA-EDE9F363CABF@mpi-bpc.mpg.de>
 <1323441811.2336.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:33580 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721Ab1LIQRx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 11:17:53 -0500
Received: from gwdexc-fe12.exc.top.gwdg.de ([134.76.9.232] helo=smtp-exc.gwdg.de)
	by mailer.gwdg.de with esmtps (TLSv1:RC4-MD5:128)
	(Exim 4.72)
	(envelope-from <Ansgar.Esztermann@mpi-bpc.mpg.de>)
	id 1RZ38Q-0007oN-6r
	for netdev@vger.kernel.org; Fri, 09 Dec 2011 17:17:18 +0100
In-Reply-To: <1323441811.2336.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 9, 2011, at 15:43 , Eric Dumazet wrote:

> It seems you have a lot of packet reorders.
>=20
> Are you using multipath or some channel bonding ?

Not that I am aware of (i.e. not on our end). However, the connection w=
ill probably routed through a firewall. I will have to check if it is c=
onfigured to avoid reordering.


Regards,

A.

--=20
Ansgar Esztermann
DV-Systemadministration
Max-Planck-Institut f=FCr biophysikalische Chemie, Abteilung 105
