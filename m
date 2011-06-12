From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 14:01:44 +0200
Message-ID: <D893CC04-58B3-43EB-8664-17DECD59A16F@comsys.rwth-aachen.de>
References: <20110611215919.5fc29c27@konijn>
 <1307850224.22348.626.camel@localhost> <20110612095131.6d924082@konijn>
 <1307869632.2872.106.camel@edumazet-laptop> <20110612113004.79f48f40@konijn>
 <1307875698.2872.130.camel@edumazet-laptop> <20110612132428.3e1a4593@konijn>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-10-1007906967
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Joris van Rantwijk <joris@jorisvr.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:61269 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753227Ab1FLMBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:01:45 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LMO00BB0EQWBEE0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sun, 12 Jun 2011 14:01:44 +0200 (CEST)
Received: from [137.226.12.53] ([unknown] [137.226.12.53])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LMO00004EQWGB00@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Sun, 12 Jun 2011 14:01:44 +0200 (CEST)
In-reply-to: <20110612132428.3e1a4593@konijn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-10-1007906967
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii

Hi Joris,

Am 12.06.2011 um 13:24 schrieb Joris van Rantwijk:

> 
> By the way, Linux does not implement the recommended (byte-counting)
> method by default. It can be enabled through sysctl tcp_abc, which is
> off by default.
> 
> 

See http://kerneltrap.org/mailarchive/linux-netdev/2010/3/3/6271114


//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-10-1007906967
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk30qqkACgkQdyiq39b9uS6IRgCgiHtzbeeAer18c4OXXcZzHYO1
MPEAn2vPoAo2dZ3jGi7G14pGrS4yNfd8
=k6Yr
-----END PGP SIGNATURE-----

--Apple-Mail-10-1007906967--
