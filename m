From: Giel van Schijndel <me@mortis.eu>
Subject: Re: [PATCH] Fix NUL (\0 or \x00) specification in string
Date: Tue, 6 Jan 2015 20:28:04 +0100
Message-ID: <20150106192804.GL4806@salidar.dom.custoft.eu>
References: <1420394722-20197-1-git-send-email-me@mortis.eu>
 <20150105150026.GG6114@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vbzKE9fGfpHIBC6T"
To: dsterba@suse.cz, linux-kernel@vger.kernel.org,
	Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	"open list:ISDN SUBSYSTEM" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khitomer.mortis.eu ([185.27.175.75]:64859 "EHLO
	khitomer.mortis.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbbAFT2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:28:08 -0500
Content-Disposition: inline
In-Reply-To: <20150105150026.GG6114@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vbzKE9fGfpHIBC6T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 05, 2015 at 16:00:26 +0100, David Sterba wrote:
> I'm replying to all your recent patches here as they are fixing things
> reported in http://www.viva64.com/en/b/0299/ . I'ts a good practice to
> give the credit the reporter.
>=20
> The blogpost also contains analyses of the issues so it could help
> reviewing the patches.

I guess you suggest I use a 'Reported-(at|by)' line?

Would something like the below suffice? I found similar log entries in the
commit log, e.g. bf3204cb, except that those add an e-mail address for
the reporters, which I don't think is necessary in this case.
> Reported-at: http://www.viva64.com/en/b/0299/
> Reported-by: Andrey Karpov
> Reported-by: Svyatoslav Razmyslov

--=20
Met vriendelijke groet,
With kind regards,
Giel van Schijndel
--
The #1 programmer excuse for legitimately slacking off:
 "My code's compiling."
  -- http://xkcd.com/303/

--vbzKE9fGfpHIBC6T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlSsN0EACgkQZBYm/87l50KjfwCePLU2pOVEgVbDw++ybwEnW5KX
CEAAoIknZIJr8qiheVWmaI9/PMzK+Kgu
=FSUB
-----END PGP SIGNATURE-----

--vbzKE9fGfpHIBC6T--
