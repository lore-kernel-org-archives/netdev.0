From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: Bad performance when CUBIC HyStart enabled
Date: Thu, 3 Mar 2011 19:12:01 +0100
Message-ID: <20110303181201.GA10487@xanadu.blop.info>
References: <20110303142229.GA9262@xanadu.blop.info>
 <1299164580.2983.99.camel@edumazet-laptop>
 <20110303173733.GB8028@xanadu.blop.info>
 <1299174383.2983.144.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sangtae Ha <sha2@ncsu.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:50865 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758451Ab1CCSLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 13:11:11 -0500
Content-Disposition: inline
In-Reply-To: <1299174383.2983.144.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/11 at 18:46 +0100, Eric Dumazet wrote:
> Le jeudi 03 mars 2011 =E0 18:37 +0100, Lucas Nussbaum a =E9crit :
>=20
> > I had 6 successful transfers. There's the netstat -s output after t=
he 5
> > first successful transfers. Then the 7th transfer showed the proble=
m,
> > as well as the 8th and the 9th. There's the netstat -s output after=
 each
> > of them.
>=20
> Its a bit strange : my 'netstat -s' are more verbose than yours :

Strange. Mine is from the debian package, and it hasn't been updated
recently, neither in Debian nor at
https://developer.berlios.de/project/showfiles.php?group_id=3D4537.
Maybe some fields are not displayed when the value is 0?
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
