From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH 2/4] Phonet: advise against enabling the pipe controller
Date: Sat, 9 Oct 2010 13:20:36 +0300
Message-ID: <201010091320.36351.remi@remlab.net>
References: <1286546523-3340-1-git-send-email-remi@remlab.net> <1286546523-3340-2-git-send-email-remi@remlab.net> <20101008.141730.258104062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:33413 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380Ab0JIKUj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 06:20:39 -0400
Received: from basile.remlab.net (cs27069010.pp.htv.fi [89.27.69.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: remi)
	by yop.chewa.net (Postfix) with ESMTPSA id 9E333483
	for <netdev@vger.kernel.org>; Sat,  9 Oct 2010 12:20:37 +0200 (CEST)
In-Reply-To: <20101008.141730.258104062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 9 octobre 2010 00:17:30 David Miller, vous avez =E9crit :
> From: R=E9mi Denis-Courmont <remi@remlab.net>
> Date: Fri,  8 Oct 2010 17:02:01 +0300
>=20
> > From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> >=20
> > As it currently is, the new code path is not compatible with existi=
ng
> > Nokia modems. This would break existing userspace for Nokia modem, =
such
> > as the existing oFono ISI driver.
> >=20
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
>=20
> This really needs to be designed such that it can co-exist with curre=
nt
> userland technology.

Yeah, don't tell me. This kinda static option works for Linux kernel on=
 an=20
embedded device like my employer. But it does not fly on the desktop.

This big patch came as a surprise, so did its merging. I don't when it =
can be=20
improved.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
