From: Mario Limonciello <mario_limonciello@dell.com>
Subject: Re: How come realtek drivers are combined
Date: Mon, 30 Jun 2008 10:24:04 -0500
Message-ID: <4868FA94.7060500@dell.com>
References: <4864235A.40807@dell.com> <20080627191835.GA5064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD80513F0691ECD35748E2ADD"
Cc: netdev@vger.kernel.org, edward_hsu@realtek.com.tw
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:19731 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbYF3PYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 11:24:08 -0400
In-Reply-To: <20080627191835.GA5064@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD80513F0691ECD35748E2ADD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Francois:

Francois Romieu wrote:
> I made it this way.
>  =20
Ah.
> Given that the choice of operating systems for laptops on Dell's online=

> shop does not include my favorite OS, "everyone" seems a bit of an
> overstatement to me (sorry, could not resist :o) ).
>  =20
You go and offer Redhat on business portables, and they want Ubuntu.=20
You offer Ubuntu on consumer portables and then they want $(INSERT
DISTRO HERE) :)
Offering this to every consumer as an option with every laptop though,
that will take some time.  For now, the consumers that want it can go to
http://www.dell.com/linux
> Compare two versions of the same driver from Realtek and you should
> realize that you are addressing a false problem.
>  =20
This is sometimes a bit difficult to do since I didn't see historical
versioning on their website.  It was a hunch, however.


Now I did see a fair deal of patches floating in from you, so I'll clone
your netdev git tree and give this a run on some of the RTL8101's that
are having trouble.

Thanks for the thorough explanation,
--=20
Mario Limonciello
*Dell | Linux Engineering*
mario_limonciello@dell.com


--------------enigD80513F0691ECD35748E2ADD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFIaPqU2CrZjkA73YsRAsT+AJ9usLHNU4sXfcZj/2neU/8dS2p+zgCfSYE7
J1klHL91dr9QIMVe7qxuj+U=
=DUWJ
-----END PGP SIGNATURE-----

--------------enigD80513F0691ECD35748E2ADD--
