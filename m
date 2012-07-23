From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 3/4] e1000e: advertise transmit
	time stamping
Date: Mon, 23 Jul 2012 01:19:21 -0700
Message-ID: <1343031561.23226.30.camel@jtkirshe-mobl>
References: <cover.1342976654.git.richardcochran@gmail.com>
	<e0e31f0229b5bfda1684122498b4d6fb3195cf26.1342976654.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3693861156196386268=="
Cc: Willem, netdev@vger.kernel.org, Bruijn <willemb@google.com>,
	David Miller <davem@davemloft.net>, e1000-devel@lists.sourceforge.net
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <e0e31f0229b5bfda1684122498b4d6fb3195cf26.1342976654.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============3693861156196386268==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-oV6rJuCOtA6p5AMPrx85"


--=-oV6rJuCOtA6p5AMPrx85
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-07-22 at 19:15 +0200, Richard Cochran wrote:
> This driver now offers software transmit time stamping, so it should
> advertise that fact via ethtool. Compile tested only.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
>=20
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: e1000-devel@lists.sourceforge.net
> ---
>  drivers/net/ethernet/intel/e1000e/ethtool.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)=20

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-oV6rJuCOtA6p5AMPrx85
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQDQkJAAoJEOVv75VaS+3O25AP/A4VGgWGXzOG2fiwncIL+nNk
WOSZhQxCMsYYnEo7bb0xsfqxxgybByCXfuWnWFRsU69JQQDUaq1r9nz80n2tM+Fi
cPkesmtw3Kwa8tKzrURziTVwvWawNmVX2tdWohyKzUQ/DzAXosSLWeGMy09TasXh
6ktAzcNANZyR1yflQIZi4p2nCiQS1dPG0stZo7y6Vt7ayjp5ugZdqFTxw0QQQHBk
4ZrIcxEKzPvhXlMa1XUveRT+8thtAAV2F3d7KHHzcDSKlzAC6sDTzO36l42Vnjz+
JWo4d4FS6wuU5kd4ujVANv2G+JUVCA8Gm5c618O2rlwcoEk+fDiVqNJjVuyqpqk1
DfyX2WgN+/gmRZdhnkhLaNsTlTUdiJ0cVq8SpDlC9bb5u77phLFGGzVB1k0qjJ8R
hjIzAac+L+4twEvMt5rfOavzI+Mtd9fTmOQVnEdfz/kn5EaD6XZtpfzwa1oZXVOQ
0mHeEEds23XiwjkLusBWUcgfot6i2wqhTuHMmybrzm9CpjDz2qWcVmD2tE3GneWn
jC5GK7LTpV12uX2pFgN3GoR3/2h6uOgfGZWbJEUMAkKUm4D37i9mK6ly71Uocqg/
U+CWoeXfDw1QSB39SCmDAbfn49mKKogpO+nT/VLXUNpe/TH2DXINGUnVl3usKEGN
j4dxAtk7mFxKZHIgL1Zg
=4GU5
-----END PGP SIGNATURE-----

--=-oV6rJuCOtA6p5AMPrx85--



--===============3693861156196386268==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
--===============3693861156196386268==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3693861156196386268==--
