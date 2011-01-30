From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: pull request: batman-adv 2011-01-29
Date: Sun, 30 Jan 2011 10:36:54 +0100
Message-ID: <201101301036.57928.sven@narfation.org>
References: <1296337660-12376-1-git-send-email-sven@narfation.org>
	<20110129.190815.226768755.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart6117253.u5B2ZLxnRN";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20110129.190815.226768755.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart6117253.u5B2ZLxnRN
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Sunday 30 January 2011 04:08:15 David Miller wrote:
> I'm not taking 13 patches in one big bunch at this point post-merge-windo=
w,
> now matter what they are.

Thats why I tried to provide the 6 bug fixes only version without polishing=
 -=20
I could also try to reduce it to a 4 critical version (oops/memleak patches=
=20
only without protocol implementation failures).

Or is the problem that I tried to get them in as pull request?

thanks,
	Sven


Here are the oops/memleak patches only:

The following changes since commit aa0adb1a85e159cf57f0e11282bc6c9e3606a5f3:

  batman-adv: Use "__attribute__" shortcut macros (2011-01-16 03:25:19 +010=
0)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/merge-oopsonly

Linus L=FCssing (1):
      batman-adv: Fix kernel panic when fetching vis data on a vis server

Sven Eckelmann (3):
      batman-adv: Remove vis info on hashing errors
      batman-adv: Remove vis info element in free_info
      batman-adv: Make vis info stack traversal threadsafe

 net/batman-adv/vis.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

--nextPart6117253.u5B2ZLxnRN
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJNRTE4AAoJEF2HCgfBJntGYF0QALHaJeF7YaW+8Rsh1NmmDiwJ
Aukk27VdXS9/5eNKk+UK/XWoKUF4qYtBlv3KewVqwfRPwS2955YlB3SqwWLmqbKY
JWyCf/0np+iU94wbTn3wMRYQ/T80Eaydj86e8NtPTLjLgW28CB/F66Sh8ZLDKbEH
Bo51I0GiJMwDLj2+YxXTDwgzJ82wzBb2Rw55LtON4orVQ+rKQdbGLk7qQJazCAxy
spO/jmP3nWwj3dGqqHYoyJrBgHHjq7BF7YzVj7EnovmSpREHaV1uSU8XWN3CjR9K
VMVW9zbVNybrzpY5ffUpowK3jxZtXfUgbCmmA0poyxjIBi54whyZffZ+bfJYoyOr
0B4WbUMCthEI1qIjwZ0pZxqQxV691+CdGToBW/Q5Wv7KVU/zsqjeFYfs4NYd0krJ
C/0tUsmxfoAq3TSUExkmZDtvLsAlPjVJ11P/+BpcfRaNqNyh0navT0jvh2grFyXf
2+HRv4OgoXSbv243LuC/dhjYLv2M1HJjWku1IT8vYE225BPb6BUZGRWzvMwE0L6U
KK2wn7U8sFQ9/YCbtJmSZlR6zBtrtTWMkTLMxZ1R71N66SNNSEy/PbwLSTKSZkZe
O9087ivsW6Mzt4UQKdjf3PPsOjm4g189wNX1zqDlr+GnJ/GacEow/ReEh8U/OjG/
jRdCT5Gux67kROWYdy52
=ElH6
-----END PGP SIGNATURE-----

--nextPart6117253.u5B2ZLxnRN--
