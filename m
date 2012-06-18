From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH] net: remove my future former mail address
Date: Mon, 18 Jun 2012 06:45:48 +0300
Message-ID: <201206180645.49266.remi@remlab.net>
References: <1339662543-7203-1-git-send-email-remi@remlab.net> <4FDAE7D5.5040709@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oyp.chewa.net ([91.121.6.101]:39012 "EHLO oyp.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376Ab2FRDpw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 23:45:52 -0400
Received: from basile.localnet (ip6-localhost [IPv6:::1])
	by oyp.chewa.net (Postfix) with ESMTP id EEA8A2005A
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 05:45:49 +0200 (CEST)
In-Reply-To: <4FDAE7D5.5040709@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 15 juin 2012 10:44:21 Sakari Ailus, vous avez =E9crit :
> Hi R=E9mi,
>=20
> R=E9mi Denis-Courmont wrote:
> > From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> >=20
> > Signed-off-by: R=E9mi Denis-Courmont <remi@remlab.net>
> > Cc: Sakari Ailus <sakari.ailus@nokia.com>
>=20
> Hmm. While you're at it, could you please remove mine from the same
> files as well, please?
>=20
> I wonder if this also means that the code will be without a maintaine=
r
> in the future.

I don't have a crystal ball. As far as I know, the ISI modem "assets" h=
ave=20
been sold to Renesas several years ago, so it would natural for them to=
 take=20
over. Or a Renesas licensee (ST-E seemed to be one at some point).

In any case, the Phonet stack has been essentially code complete from t=
he=20
beginning: the changes with new modems occur either above in userspace,=
 or=20
below in device drivers. In the past few years, it boiled down to keepi=
ng it=20
up to date with kernel internal changes.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
