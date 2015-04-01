From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] Intel Wired LAN Driver Updates
Date: Tue, 31 Mar 2015 19:19:53 -0700
Message-ID: <1427854793.20936.4.camel@jtkirshe-mobl>
References: <1427497451-23642-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20150331.132214.1693397186943204005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VSvirCtG5uTT41IVzaiO"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, linux.nics@intel.com,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150331.132214.1693397186943204005.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VSvirCtG5uTT41IVzaiO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-31 at 13:22 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 27 Mar 2015 16:04:10 -0700
>=20
> > The following are changes since commit
> dde93dfea53c72b07907d9e44a6e4b1545f6bdc4:
> >   cxgb4: Fix frame size warning for 32 bit arch
> > and are available in the git repository at:
> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue
> master
> >=20
> > Jeff Kirsher (1):
> >   MAINTAINERS: Update Intel Wired Ethernet Driver info
>=20
> Looks great but it looks like nothing is pushed there?
>=20
> [davem@localhost net]$ git pull
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue
> master
> From git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue
>  * branch            master     -> FETCH_HEAD
> Already up-to-date.
> [davem@localhost net]$

Sorry, I forgot to scrub the cover letter to remove the "pull" info,
since it was a single patch, I did not think it would require a
"pull". :-)

I can apply it to my net-queue tree, master branch if you need or want.

--=-VSvirCtG5uTT41IVzaiO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVG1XJAAoJEOVv75VaS+3OVggP/2MKtCNxLs4zmSk4pqFqVI+e
KcWenhFimR/fWaAk6CLfJ1F4kKsI6xvkti6gxxv3A63/AQgjNxhgdFq72xcLFS7G
oJPZKJi24ZvPhVfJ8aUbpSlyraNnh3UT0XGyOM00J/JHSHsnhtd46Ey+5+4ak6F0
q5uae674zEcjTYNZJrJkryPUu2WlQRBE7JFC3tJBESLstQBL4CEqcCFerzuGGuNN
hlsGULU3w5kj+oA+wLVfkP2xrPJXyFfZbtZLzGCJrPEoFRC41da/KE9hLAX1w5hS
P41hTNysDlQOFQsxJAfSA9WHGgkIGI5nx1r0y1euhqNh+X7/F3qNVbr3eZh1kEhr
F0WLAQnCUlH2M6aWTdiwFW06d1J2kaNRPpDw942ITL6WjpJN3j1NNCBHua2ljmo0
GLapf+5H0zaPQkvERArXvr5ubNM8FTVqMCcmhmhVhWlQLvvPzOq+EPdm/yjNJYNK
WZev6EjQ7BvYZ2VzpS2hari9ZqF7qtC6TMFw5qNYkvR3SgZ+OhVBG+ZVy2LpKUfH
0hWIjuUeUIn7Y3BxfyzvHf5am7lXFe9tpVC0UxX24bAmwhdHrm6+64OJ1dPwpwOn
iWfW/CRDVZNsCmJ92HSvvFYa2K0yGa7maBY4WfNAMMDBqklp6ZPjkRu4EINetSiC
VvkcceOJcB09+LW/9ymX
=5nzU
-----END PGP SIGNATURE-----

--=-VSvirCtG5uTT41IVzaiO--
