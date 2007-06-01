From: =?iso-8859-1?b?RW1tYW51ZWwgRnVzdOk=?= <emmanuel.fuste@laposte.net>
Subject: Re: [PCNET32] Lock solid with netconsole
Date: Fri,  1 Jun 2007 13:21:36 +0200
Message-ID: <JIYFK0$B8CAA66FE1370ED3888684BC888C4946@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "tsbogend" <tsbogend@alpha.franken.de>,
	"lsorense" <lsorense@csclub.uwaterloo.ca>,
	"pcnet32" <pcnet32@verizon.net>, "netdev" <netdev@vger.kernel.org>
To: "romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.laposte.net ([81.255.54.16]:14450 "EHLO mx.laposte.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750719AbXFALWC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 07:22:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> Emmanuel Fust=E9 <emmanuel.fuste@laposte.net> :
> [..]
> > Could this bug fix from Stephen Hemminger be another track to follo=
w ?
> > http://marc.info/?l=3Dlinux-netdev&m=3D118048588011069&w=3D2
> > If you think so, I could give it a try whitout applying the "spin_l=
ock_irqsave" patch.
>=20
> You can apply it too but Stephen's patch addresses a different issue =
and
> pcnet32 does not use netif_tx_locking (it could/should though).

Hello,
Did you plan to submit the "spin_lock_irqsave" patch to mainline ? or w=
e have to wait for a "real" fix ?

Thanks,
Emmanuel.
---

Cr=E9ez votre adresse =E9lectronique prenom.nom@laposte.net=20
1 Go d'espace de stockage, anti-spam et anti-virus int=E9gr=E9s.

