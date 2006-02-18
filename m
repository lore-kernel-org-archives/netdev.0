From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Please pull upstream branches of bu3sch.de
Date: Sat, 18 Feb 2006 02:19:57 +0100
Message-ID: <200602180219.57775.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart17822491.vhpR87gUrp";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
   Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
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

--nextPart17822491.vhpR87gUrp
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi John,

I rebased my repository at
git://bu3sch.de/wireless-2.6.git

Please pull the following changes from "softmac-upstream":
Michael Buesch:
      bcm43xx: fix txpower reporting in WE.
      bcm43xx: enable SPROM writing.
      bcm43xx: heavily increase mac_suspend timeout.
      bcm43xx: fix compiletime warning (phy_xmitpower)
      bcm43xx: remove WX debugging.
      bcm43xx: Partially fix PIO code. Add Kconfig option for PIO or DMA mo=
de (or both).
      bcm43xx: add a note that not all devices support PIO.
      Apple Airport: Add Kconfig note that the bcm43xx driver has to be use=
d for Airport Extreme cards.
      bcm43xx: update README
      bcm43xx: fix LED code.
      bcm43xx: rewrite and simplify the periodic task handling.
      bcm43xx: Code cleanups. This removes various "inline" statements and =
reduces codesize.

Please pull the following changes from "dscape-upstream":
Michael Buesch:
      bcm43xx-d80211: build magic add_sta binary in /tmp instead of $PWD
      bcm43xx-d80211: fix NULL pointer deref in bcm43xx_remove_one.
      bcm43xx-d80211: heavily increase mac_suspend timeout.
      bcm43xx-d80211: remove WX debugging.
      bcm43xx-d80211: Update docs to reflect changes in the driver.
      bcm43xx-d80211: fix LED code.
      bcm43xx-d80211: Code cleanups. This removes various "inline" statemen=
ts and reduces codesize.

I don't append the diffs, as they are rather big.
If you want to review the changes, I suggest you look at the
webinterface of my repository:
http://bu3sch.de/git?p=3Dwireless-2.6.git;a=3Dsummary

Stefano, please re-clone your copy now.

=2D-=20
Greetings Michael.

--nextPart17822491.vhpR87gUrp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD9nY9lb09HEdWDKgRAhi2AKCzWFBrtpg+IjSfqk7flYH/k55C0gCfS5cp
hFz6bGvKWUX0qT0NnRo/qH0=
=wAPl
-----END PGP SIGNATURE-----

--nextPart17822491.vhpR87gUrp--
