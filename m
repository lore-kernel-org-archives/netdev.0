From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: New trees - ipsec and ipsec-next
Date: Fri, 25 Jan 2013 10:20:36 +1100
Message-ID: <20130125102036.c04539e1b0beb2f44f8394cd@canb.auug.org.au>
References: <20130124061315.GI9147@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__25_Jan_2013_10_20_36_+1100_/z8INOA_5h4.dzCH"
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:49990 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818Ab3AXXUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 18:20:46 -0500
In-Reply-To: <20130124061315.GI9147@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__25_Jan_2013_10_20_36_+1100_/z8INOA_5h4.dzCH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Steffen,

On Thu, 24 Jan 2013 07:13:15 +0100 Steffen Klassert <steffen.klassert@secun=
et.com> wrote:
>
> could you please add the ipsec and ipsec-next tree to linux-next?
>=20
> The ipsec tree is intended to cover fixes for the ipsec networking
> subsystem and the ipsec-next tree to cover changes for ipsec with
> linux-next as target.
>=20
> The trees are located at:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master
> git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git mas=
ter
>=20
> The ipsec tree follows David Miller's net tree, the ipsec-next tree follo=
ws
> the net-next tree. So they should be merged after net and net-next.

Added from today with just you as the contact.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgment of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
	Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

Legal Stuff:
By participating in linux-next, your subsystem tree contributions are
public and will be included in the linux-next trees.  You may be sent
e-mail messages indicating errors or other issues when the
patches/commits from your subsystem tree are merged and tested in
linux-next.  These messages may also be cross-posted to the linux-next
mailing list, the linux-kernel mailing list, etc.  The linux-next tree
project and IBM (my employer) make no warranties regarding the linux-next
project, the testing procedures, the results, the e-mails, etc.  If you
don't agree to these ground rules, let me know and I'll remove your tree
from participation in linux-next.

--Signature=_Fri__25_Jan_2013_10_20_36_+1100_/z8INOA_5h4.dzCH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRAcHFAAoJEECxmPOUX5FESh4P/0xaWNcU9Ki3RPwxPjhIT9yJ
JEKS5w0PTwPeqJnwqIWz/glB4jEC45Uskvwn/QFmXfFPcQVWBYuyDaHhKgq5hk+r
K8wAT2zOhq1ZLouA42So6vt+pXtwImOMl7E1V0rSvxFzvQpBI+Vx2nPNQ3DkRwC2
JtEF0rtqqM2rcsgWUkWhm1Rc37r8zuj9PbxipqX1dUlZ68yQpsObBxUwk02336Z6
Br3WhK1zmYqwzJkVPf/PiY0L/3pp3clrr9PAIpWBJVy50pN8HkmUgaZjjPORU8r9
DXvMwZc3UuaUcc/utTUwVEhCA5/UPvCkQ2AtWF9jhBEu7KUfF4KHiK8fNqacKn02
657RVASjf1lsme3ukwB8MGtiGCWdeBKdNiPN8j03Z5PgyBAyW/BE2fyv1i7XUnS0
sHj7sx/VUdHrW//mJWYx22xy9Vl3zN+nhTgT7IRD8IlvnCYqeDaSbatgyGg5UtZo
48mPC9nxupQhFeTqbebWJrIF1XgIEocSc+P+xttbDceRFFQbZ+tkUQpMBaqsLZ2N
JFayp0ByJUGHETJO5VibMlKVjyvns5JLAzm7xnv+6cNoOEecAdmU/tG3eRBb6P3U
9CtlwZHGJ4VBLXaGN/l3t+ctlIG5E5wDjZvLTbiv8tyK2fqLNn8tBYATGxyMMThj
JImb8I53N+v4Cd9gTwop
=17vy
-----END PGP SIGNATURE-----

--Signature=_Fri__25_Jan_2013_10_20_36_+1100_/z8INOA_5h4.dzCH--
