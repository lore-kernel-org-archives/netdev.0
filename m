From: Willy Gardiol <willy@gardiol.org>
Subject: Re: The 8169 driver: issue with cross cable
Date: Sun, 6 Mar 2005 20:29:01 +0100
Message-ID: <200503062029.04189.willy@gardiol.org>
References: <200502192011.25428.willy@gardiol.org> <200503061252.01160.willy@gardiol.org> <20050306160358.GA2712@electric-eye.fr.zoreil.com>
Reply-To: willy@gardiol.org
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2338345.tWyRzniHhu";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050306160358.GA2712@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2338345.tWyRzniHhu
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


I must correct myself, the problem persist even if i use only one r8169. Ju=
st,=20
it is less frequent.

bye

Alle Sunday 06 March 2005 17:03, hai scritto:
> Willy Gardiol <willy@gardiol.org> :
> [...]
>
> > So, i had not been able to test the r8169 with the patched 2.6.11.
> >
> > Always ready to help...
>
> Can you try:
> - 2.6.11 + r8169-470.patch + r8169-480.patch
> - 2.6.11-mm1 + r8169-470.patch + r8169-480.patch
>
> Even if the kernel do not work, I'd welcome their compressed .config.
>
> --
> Ueimor

=2D-=20

!=20
 Willy Gardiol - willy@gardiol.org
 www.gardiol.org
 +39 3492800983
 Use linux for MY freedom.=20
 Your freedom may come as a side effect.

   "La guerra non far=E0 mai finire=20
    alcuna guerra, nel migliore dei
    casi sar=E0 stata una guerra in pi=F9."

      Gino Strada, Buskash=EC


--nextPart2338345.tWyRzniHhu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCK1oAvgbSPju7wvkRAqz0AKDVXga8YcaeY7pw0mK8Pj8u3dWu2wCgjCDf
CIIqSSa7pifkcwCQJIVyeH8=
=63Zc
-----END PGP SIGNATURE-----

--nextPart2338345.tWyRzniHhu--
