From: Raphael Hertzog <raphael@ouaza.com>
Subject: Re: Constantly varying download rate with a complex xen networking
 setup, why?
Date: Wed, 17 Jun 2009 15:00:50 +0200
Message-ID: <20090617130050.GA18586@rivendell>
References: <20090615075313.GA22819@rivendell>
 <Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI>
 <20090615160254.GA8550@rivendell>
 <Pine.LNX.4.64.0906151910220.16408@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-15?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakeen.ouaza.com ([212.85.152.62]:45202 "EHLO
	arrakeen.ouaza.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765505AbZFQNAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 09:00:53 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906151910220.16408@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 juin 2009, Ilpo J=E4rvinen a =E9crit :
> Maybe the proxy interferes there somehow... I don't know enough about=
 the
> details to say but I suppose the proxy at least breaks your tcp conne=
ction=20
> to two parts.

Indeed. Is there some processing done in a simple linux bridge where th=
e
reapperance of the same TCP packet that has been created and sent on an=
other
local interface could create problem?

> > How can I collect those information?
>=20
> Perhaps it's enough to just know if sshs that stall go over the adsl =
link=20
> too or are they local? If they're local it's sort of pointing to some=
thing=20
> else (of which I probably have no clue).

The ssh connection was local and did not go over the ADSL link.

Cheers,
--=20
Rapha=EBl Hertzog -+- http://www.ouaza.com

=46reexian : des d=E9veloppeurs Debian au service des entreprises
http://www.freexian.com
