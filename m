From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [next-net 00/19][pull request] Intel Wired LAN Driver Updates
 2017-02-02
Date: Fri, 03 Feb 2017 15:15:09 -0800
Message-ID: <1486163709.2409.36.camel@intel.com>
References: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
         <20170203.162846.1286497539881724174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-8C0Pi5F01tWohKVnbzoH"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:48196 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753017AbdBCXPL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 18:15:11 -0500
In-Reply-To: <20170203.162846.1286497539881724174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8C0Pi5F01tWohKVnbzoH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-02-03 at 16:28 -0500, David Miller wrote:
> Pretty sloppy submission Jeff.
>=20
> First of all, things are getting backlogged way too much.=C2=A0 19 patche=
s
> is too large, you need to keep it closer down to 10 and the very very
> low teens.=C2=A0 You need to send me pull requests more often so that thi=
s
> does not happen.
>=20
> Second of all, all of your Subjects are messed up and have "queue"
> misspelled and things like this.
>=20
> Finally, there is nothing to even pull at the URL you provided:
>=20
> [davem@dhcp-10-15-49-210 net-next]$ git pull --no-ff
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master
> From git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
> =C2=A0* branch=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 master=C2=A0=C2=A0=C2=A0=C2=A0 -> FETCH_HEAD
> Already up-to-date.

I truly apologize, I had to move my kernel patch scripts to a new system
and did not catch the mis-spelled tree, which caused the mis-spellings in
the patches and the reason that it did not appear on my kernel.org tree.

I am also sorry for sending 19 patches in an attempt to "catch up" for my
being incommunicado over the last couple of months.  This is all my fault
and I am not going to go into all the personal crap I have been going
through which caused me to drop the ball over the last several months.

I will fix up this submission and reduce the number of patches.
--=-8C0Pi5F01tWohKVnbzoH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYlQ79AAoJEOVv75VaS+3ORUQP/igmr+ZfWx/ILxRDF8B0dA2s
dA067lZU9CS+IwkeENBR29QiuOf52fHRAakumj0ODA7zKqCrj7Harls0wChoKgiG
ZptoSjrfta6U00eK0DeJ4dAgldvzb33w2HP6IMm43yOIcKHhvOh2iqJhOhbgr7N6
b9rgkw43gCVliYVchvznQ68arQbS/TU6hUwtEw4ushLSdAsfT0BeDqiOFo+DIaqx
YhbbE0XwZm6tpC2z3HwhI1PU57ZFK/eotbEER7Fo7LZDf2kfcVjDqmUOAxr04skG
m6ona1esirONwvWsdZlkWC7zwfB1ISuRdI7jIHUV07DUxSodYSuQ99dQBtCP/oqe
pEsCEMc3ky2wSlKPzulcya0aSKhqucaODh6B7Xd9PMQ6p+wJiSSsFQ/7rDOun7e0
ogef6NeySdJDS6LS4kLkQ50eVYmJoF1ORUaRo8xyrzmcbTw/JR7TO2FtkvCebkhN
2/Gdf4gZmA9vGUJ342S2tefE5iljy6l3yjL4lvwiNWQ9kg16WQFmDa81ctfc2QMl
PKvSUhtO8oqVdRvvKcV1NF9gyH5iHHZtnKoIqSBpyToIQoaVayGd4pPuDk6YSSGK
EQ/75WaU3WN98QBh8kUvGTV2+sutR50I7A8eReb7WGLaCnbUAWuZyl/HK/OJtYt+
f1sV1kCjsFtV1GHuznN5
=N1uG
-----END PGP SIGNATURE-----

--=-8C0Pi5F01tWohKVnbzoH--
