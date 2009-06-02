From: Pascal Terjan <pterjan@mandriva.com>
Subject: Re: SiS 191 failure with MTU > 1496
Date: Tue, 02 Jun 2009 13:50:49 +0200
Message-ID: <1243943449.19053.96.camel@plop>
References: <1243615486.12871.44.camel@plop>
	 <1243615800.12871.45.camel@plop> <1243616449.12871.49.camel@plop>
	 <20090529223047.GA29073@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ryu.zarb.org ([212.85.158.22]:34821 "EHLO ryu.zarb.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760083AbZFBLut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 07:50:49 -0400
In-Reply-To: <20090529223047.GA29073@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 30 mai 2009 =E0 00:30 +0200, Francois Romieu a =E9crit :
> Pascal Terjan <pterjan@mandriva.com> :
> [...]
> > Oh and even
> > http://bugzilla.kernel.org/show_bug.cgi?id=3D10694
>=20
> Yes, it sucks.
>=20
> > Should I add some info there ?
>=20
> Not yet but could you retry with RX_BUF_SIZE set to 1544,
> 1528 and 1520 ?
>=20

1544, 1528 and 1520 fail the same way

