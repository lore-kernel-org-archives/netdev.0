From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [RFC 2/3] if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
Date: Mon, 5 Dec 2011 17:46:14 +0200
Message-ID: <201112051746.18180.remi@remlab.net>
References: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com> <ff290c739be323dec89d19ed905feb94@chewa.net> <CAJK669ZhM_KSOd0MS7jTVvJ16KqNzPCj-Ns1ytN5NPg5PxgoOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexey Orishko <alexey.orishko@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Sjur =?utf-8?q?Br=C3=A6ndeland?= <sjurbren@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:38725 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932348Ab1LEPqW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 10:46:22 -0500
In-Reply-To: <CAJK669ZhM_KSOd0MS7jTVvJ16KqNzPCj-Ns1ytN5NPg5PxgoOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 5 d=C3=A9cembre 2011 16:33:50 Sjur Br=C3=A6ndeland, vous avez =
=C3=A9crit :
> Hi R=C3=A9mi,
>=20
> > It's even weirder then. If you have control over both ends and the =
NCM
> > 1.0 interface is not adequate, then you really should use your own =
CDC
> > class for the purpose.
>=20
> The reason we use NCM is performance: CDC normally gives less than 10=
0Mbps,
> while NCM can give you up to 200Mbps.

NCM is a sub-profile of CDC, so that statement makes no sense to me.

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
