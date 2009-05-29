From: Pascal Terjan <pterjan@mandriva.com>
Subject: Re: SiS 191 failure with MTU > 1496
Date: Fri, 29 May 2009 19:00:49 +0200
Message-ID: <1243616449.12871.49.camel@plop>
References: <1243615486.12871.44.camel@plop>
	 <1243615800.12871.45.camel@plop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ryu.zarb.org ([212.85.158.22]:56559 "EHLO ryu.zarb.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753691AbZE2RAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 13:00:49 -0400
In-Reply-To: <1243615800.12871.45.camel@plop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 mai 2009 =E0 18:50 +0200, Pascal Terjan a =E9crit :
> Le vendredi 29 mai 2009 =E0 18:44 +0200, Pascal Terjan a =E9crit :
> > On a laptop with such hardware, with default 1500 MTU I can't conne=
ct to
> > local machines, error bit LIMIT is set when receiving packets.
> >=20
> > By decreasing the MTU to 1496 everything works fine.
> >=20
>=20
> This looks like a known issue
>=20
> http://bugzilla.kernel.org/show_bug.cgi?id=3D10895
> https://bugs.launchpad.net/ubuntu/+bug/369513

Oh and even
http://bugzilla.kernel.org/show_bug.cgi?id=3D10694

Should I add some info there ?

