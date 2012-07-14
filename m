From: valdis.kletnieks@vt.edu
Subject: Re: resurrecting tcphealth
Date: Fri, 13 Jul 2012 21:31:52 -0400
Message-ID: <3436.1342229512@turing-police.cc.vt.edu>
References: <e9caf38359467bfa8a1e2ac86f6ef2cc.squirrel@webmail.univie.ac.at>
            <20120713165544.6767ea8f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1342229512_2294P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: "Piotr Sawuk" <a9702387@unet.univie.ac.at>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:57958 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab2GNBcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 21:32:05 -0400
Received: from zidane.cc.vt.edu (zidane.cc.vt.edu [198.82.163.227])
	by lennier.cc.vt.edu (8.13.8/8.13.8) with ESMTP id q6E1SoXO009333
	for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 21:32:04 -0400
Received: by qaeb19 with SMTP id b19so678992qae.4
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 18:31:54 -0700 (PDT)
In-Reply-To: Your message of "Fri, 13 Jul 2012 16:55:44 -0700."
             <20120713165544.6767ea8f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1342229512_2294P
Content-Type: text/plain; charset=us-ascii

On Fri, 13 Jul 2012 16:55:44 -0700, Stephen Hemminger said:

> >+			/* Course retransmit inefficiency- this packet has been received twice. */
> >+			tp->dup_pkts_recv++;
>
> I don't understand that comment, could you use a better sentence please?

I think what was intended was:

/* Curse you, retransmit inefficiency! This packet has been received at least twice */

--==_Exmh_1342229512_2294P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUADMBwdmEQWDXROgAQJUqw/9HmNIPSdsQleef27JibtBPdrjpDEqYugB
TTgRHjWd2VTR4x6AP2OIqqSA/Fb4VWmo6t7jCuXK7fGkCVQ4ut9iA40NeTpcwUu/
Qt8lQxmzIXJjj9fotdW6djrg3MOo/w7DMa+86XoQJ+XmmSKR9HMSw0XHNco8D2+l
Q/SlDw53T0VTuK5V9sEddczAf83ZsOo/hbXXG/vlLcw+VNaM18l366ZGV7BDsHqk
EC6tQmjOuSY6I3zuOX9fVv7uOiQPgvGS0aGLmUuWSxLUDgSyisuIZbF0ha9+0FRe
/KQMOS4aW/ZEmnY7AtyqiViOtmrsSYL9pu4Ub4Nc8XFQZ8ONDBGQDHWUiUInxrzv
sYwNHBvSzzpD5fK3jMQBPAto/oFWoH2ImNl8zeLEkAHaUe0LHv2L+ylXlzsOwBg+
4kQi50eFZg1TjdnWUgI+Oo0CE9chSPh9eOEVzN3V0KKmCD4Ztv9XaiVxb/TqtyiX
8IWS0+dv9RSiiCyao/eK8eHBVTfHknLKoZAn+gp6aV6HYPr0W23UXyR0jBlpeXTm
IeJuShY6+cm4A15xhKzDnc9UodD9XU3D0rhbjilbSFBVaNjrcI8nroOZI1gWVRNx
RSSPeY9VbVtjLgVOAq0c9+HCNaiA+l6YGtbiCpn6IyDnBlEMUbt4OcnzK+/MYNy4
yV8ABGbq95k=
=e6fp
-----END PGP SIGNATURE-----

--==_Exmh_1342229512_2294P--
