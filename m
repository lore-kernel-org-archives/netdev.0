From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: using is_zero_ether_addr() to
	simplify the code
Date: Sun, 26 Aug 2012 01:51:13 -0700
Message-ID: <1345971073.2306.1.camel@jtkirshe-mobl>
References: <CAPgLHd_4FkMaEuBBbjSEFnQzP8=x0EeT=6Z1LNiHE7ycOvNziQ@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3878320075366906262=="
Cc: e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, yongjun_wei@trendmicro.com.cn,
	john.ronciak@intel.com, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAPgLHd_4FkMaEuBBbjSEFnQzP8=x0EeT=6Z1LNiHE7ycOvNziQ@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============3878320075366906262==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PuUYkdDqGYaoDNVeOf9A"


--=-PuUYkdDqGYaoDNVeOf9A
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-08-26 at 08:53 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> Using is_zero_ether_addr() to simplify the code.
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)=20

I have added the patch to my queue of patches.  Thanks!

--=-PuUYkdDqGYaoDNVeOf9A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQOeOBAAoJEOVv75VaS+3OiIQP/1JrjySCD5hZCD7kY2ulAUBF
+OV/Tc6//tUFMCUSHXyw2k3tcIMRG2g9TXIiKRneU2q44XspwJGCqrs/TGBZ4VKx
BKWuL2N2CN/DP5VrdD43Y7411/eQpLmCuiP1QwQ/bHwH7ZmwQvKmB07HPWIhDSuI
ULd7OGB2OI7AOHFq9Gde5gEmG3zx2w5UqwWrOPOfCjFA6LCv6x9HXS8hJ/zyE8dy
Eicikgdd2ekXkrsiTBOjBcA/fTYSLu9IDIc6BQTlkxE7GrIFMBxFD+KY0awSbS1W
MGu7tI4CoGyhXJDXfw8jGExKM+RjIyyfV+aL8JceDG5Z5fWjNmoIWyXWOTGwjUSo
N/+SmFj4Ps2n2LjW7GubearSA8x/UJcyuTXYa1UywynhOqBkEcGQ7MSnqSrOJet4
tL7yny3Y//Bt6Os5naR23nG26mU6jaC9vjaDQFvixRwm/1dSrBVgriN8/cwvzorK
f9uMfPHu43eajPRkdha6zDFh46TWnDmIwrkHQyauC8LFjCMxfogKAyfeV9111zyA
rKpKkXlwCFphgFZhfeEHjy1ljc3cZYByiVUScWpZSdNiMW/UqHkJLv2E6xF9pIKd
C9zdJ6UqA1ffLz44vU7CtN+boe6wnU0P6zgsOu/sK6OG6u1BSnQGV+nKyMi+Dr9r
h6QNsWPlBAoVETDIvafN
=PDcO
-----END PGP SIGNATURE-----

--=-PuUYkdDqGYaoDNVeOf9A--



--===============3878320075366906262==
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
--===============3878320075366906262==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3878320075366906262==--
