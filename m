From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: Fwd: Network Core
Date: Wed, 5 Nov 2008 19:52:20 +0200
Message-ID: <200811051952.20745.rdenis@simphalempin.com>
References: <530d01580811050939q1c1dc52fra6fc2078d86d36e@mail.gmail.com> <530d01580811050940k2010ba3fpd0973f23e390c5e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Diego ." <eljedi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:34609 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339AbYKERwY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 12:52:24 -0500
In-Reply-To: <530d01580811050940k2010ba3fpd0973f23e390c5e7@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello!

Le mercredi 5 novembre 2008 19:40:45 Diego ., vous avez =E9crit=A0:
> Could you point me to somewhere i can find some info about howto to
> port/create a network protocol to/on linux? ( i mean, some basic info
> like the one we can find with the fs layer. I'm not asking about a
> magic tutorial about how to port my protocol ). Or some basic network
> layer info.

My experience with taking over maintainance of the Nokia Phonet stack i=
s that=20
there is no such documentation.

http://vger.kernel.org/~davem/ contains some basic infos, especially us=
eful=20
w.r.t. network buffer management. Other I stick to the Linux Cross Refe=
rence=20
at http://lxr.linux.no/ and read the source code. Some of the simpler n=
etwork=20
layers (_not_ IPv4 neither IPv6) can be useful as a basic reference (I =
read=20
through CAN quite a abut).

Hope this helps,

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
