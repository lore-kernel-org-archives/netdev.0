From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: wireless 2.6 work
Date: Wed, 9 Mar 2005 21:50:36 -0500
Message-ID: <20050310025036.GE17854@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qtZFehHsKgwS5rPz"
Cc: Netdev <netdev@oss.sgi.com>,
        "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--qtZFehHsKgwS5rPz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Jeff,

I'm sick off the low activiity and slow support on wireless we have. I
know you're busy so I wanted to offer my help in helping around work on
wireless-2.6, now that I have time after work, and before I commit
myself to anything else. It's a bit suicidal, but oh well. Oh yeah and
I'll also start using bitkeeper due to the recent clarifications on the
license of its usage.

I'll willing to review as much patches as I have to and also hopefully
write documentation on writing new wireless drivers. That said, if I can
be of any assistance, where what you like me to start on?

Here's what's on my agenda so far:

* Help cleanup new ralink driver, start using ieee802211 and get into wirel=
ess-2.6.
* Push prism54's new WPA and WDS support into wireless-2.6
* Start seeing what I can use off of ieee80211 for prism54, clean it,
  and move to wireless-2.6
* Start incorporating WPA through wpa_supplicant onto as many drivers
* Start standardizing all things a bit, as bitched about and well pointed o=
ut
  by Dan Williams <dcbw@redhat.com>
* Listen to Jouni, he's the man

Ideally I think Jouni should be the guy doing all this but I think he
just has no time.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--qtZFehHsKgwS5rPz
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCL7X8at1JN+IKUl4RAvk3AJ0QQqWpNIwDCdsWYCS6hiXHuq1vlgCfVWW9
L+uWdSVstIk5JZ3618V9sAw=
=PhGp
-----END PGP SIGNATURE-----

--qtZFehHsKgwS5rPz--
