From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Re: [PATCH wireless-2.6] bcm43xx-d80211: fix oops when removing the module
Date: Thu, 16 Feb 2006 10:54:14 +0100
Message-ID: <200602161054.14554.mbuesch@freenet.de>
References: <20060215202147.69b82ee2@griffin.suse.cz> <200602152234.35463.mbuesch@freenet.de> <20060216103543.5a96f0a0@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2310558.Br3iEzypS5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
In-Reply-To: <20060216103543.5a96f0a0-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

--nextPart2310558.Br3iEzypS5
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 16 February 2006 10:35, you wrote:
> On Wed, 15 Feb 2006 22:34:35 +0100, Michael Buesch wrote:
> > On Wednesday 15 February 2006 20:21, you wrote:
> > > This patch fixes an oops when bcm43xx-d80211 module is unloaded.
> > This is already fixed in my tree.
>=20
> Is the tree available somewhere? I'm testing some patches for the d80211
> stack and it will help me if I can pull the latest bcm43xx version to my
> local repository.

sure.
git://bu3sch.de/wireless-2.6
branches dscape-all and softmac-all. The other branches are unused and
the result of the initial linville clone. ;) I should probably clean
it up a little bit, but I did not care, yet.

=2D-=20
Greetings Michael.

--nextPart2310558.Br3iEzypS5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD9EvGlb09HEdWDKgRAuPyAJ0TYn9+b0DeM5s2dfPmaA6fbITrMQCeP7IZ
burv4eS/GfIB38FeuBG+3Ls=
=R40K
-----END PGP SIGNATURE-----

--nextPart2310558.Br3iEzypS5--
