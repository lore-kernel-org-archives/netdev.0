From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: [GIT PULL] bcm43xx update
Date: Fri, 27 Jan 2006 18:42:54 +0100
Message-ID: <200601271842.54347.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3091339.ZCBcMmvlO1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
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

--nextPart3091339.ZCBcMmvlO1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi John,

I synced my git repository with the bcm43xx SVN repository.
I will continue to develop the driver in git, so these ugly syncing
will not be needed any longer. I will poke you from time to time
to pull from my repos. (I don't know how the other bcm43xx developers
will handle it. I suggest they set up a git repository, too)

Please do a
git pull git://bu3sch.de/bcm43xx.git master-upstream
to pull the bcm43xx-softmac branch.

Please do a
git pull git://bu3sch.de/bcm43xx.git dscape-upstream
to pull the bcm43xx-dscape branch.


master ShortLog:

Michael Buesch:
      [bcm43xx] sync with svn.berlios.de
      [bcm43xx] remove linux version compatibility code.
      [bcm43xx] Move README file to Documentation directory.
      [bcm43xx] remove redundant COPYING file.


dscape ShortLog:

Michael Buesch:
      [bcm43xx] sync with svn.berlios.de
      [bcm43xx] Move documentation to Documentation subdirectory and move s=
cripts to scripts subdirectory.
      [bcm43xx] Remove redundant COPYING file.

=2D-=20
Greetings Michael.

--nextPart3091339.ZCBcMmvlO1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD2luelb09HEdWDKgRAuJGAJ9a+y3SPuMxLG3ouJX0j6ScmJOpMQCgpLCt
loCGOOmdh71OMojpaQBb9h8=
=5GYo
-----END PGP SIGNATURE-----

--nextPart3091339.ZCBcMmvlO1--
