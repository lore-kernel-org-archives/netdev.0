From: Harald Welte <laforge@netfilter.org>
Subject: Re: RFC: promote netfilter MARK value from IPv6 packets to sit packets
Date: Mon, 24 Feb 2003 15:41:16 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030224144116.GN24960@sunbeam.de.gnumonks.org>
References: <20030217145727.GA3413@hensema.net> <20030223193339.GD15385@sunbeam.de.gnumonks.org> <20030223234225.GA23556@hensema.net> <20030224083946.H34066@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lYetfuAxy9ic4HK3"
Cc: Erik Hensema <erik@hensema.net>, Harald Welte <laforge@netfilter.org>,
	netdev@oss.sgi.com,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20030224083946.H34066@shell.cyberus.ca>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--lYetfuAxy9ic4HK3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 24, 2003 at 08:41:10AM -0500, jamal wrote:
> If this is to be a config option, it should not be restricted to
> netfilter specifics but rather skb specifics. Example the tcindex
> (maybe even the cb) etc.

No problem with me.  I do understand the usefulness of tcindex, but what
would a totally different protcol (or the user) do with the cb of a
different protocol?

> cheers,
> jamal

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--lYetfuAxy9ic4HK3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE+Wi8MXaXGVTD0i/8RAmfCAJsGL4Ga6R62Yezoj1HCJWC58wWR5gCfcEsv
1Bm/rI31ua78Rs9d20eNLfw=
=mrzP
-----END PGP SIGNATURE-----

--lYetfuAxy9ic4HK3--
