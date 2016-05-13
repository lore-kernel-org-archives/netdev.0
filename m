From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH v7 00/21] Add HiSilicon RoCE driver
Date: Fri, 13 May 2016 17:09:39 -0400
Message-ID: <ee4fe6df-e9b0-28da-c960-c288d6617025@redhat.com>
References: <1462849483-67927-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="EdjFGaXEAr61LuLmHVlr8sxX9ipGHrGa3"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462849483-67927-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EdjFGaXEAr61LuLmHVlr8sxX9ipGHrGa3
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/09/2016 11:04 PM, Lijun Ou wrote:
> The HiSilicon Network Substem is a long term evolution IP which is
> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
> Sybsystem) also has a hardware support of performing RDMA with
> RoCEE.
> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
> will support mulitple versions of SOCs in future. This version of drive=
r
> is meant to support Hip06 SoC(which confirms to RoCEEv1 hardware
> specifications).
>=20
> Changes v6 -> v7:
> 1. modify some type of parameter, use bool replace the original type.
> 2. add the Signed-off-by signatures in the first patch.
> 3. delete the improper print sentence in hns_roce_create_eq.

One thing you should be aware of (but which you may not care about,
which is fine) is that if you want your driver to be available as part
of the OpenFabric Alliances OFED distribution, the license on the files
would need to be "GPL or BSD" (see the remainder of the RDMA stack for
examples).  If you don't want that license on your files, I'm fine with
that, and I won't hold up your submission based on the license.  If,
however, you *do* want your code to be shipable as part of OFED, it is
much easier to update the license on the files before you submit them
and third parties modify them.  If you want to change the license later,
you have to get every person that has made any substantive change to the
file to agree to the license change.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--EdjFGaXEAr61LuLmHVlr8sxX9ipGHrGa3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNkKTAAoJELgmozMOVy/drEsP/R2CqLByXp0pcEluRItRQuiN
Bq/1NsUB6WcodZAN+QwoP9G4tXCU7G/N4d5MnkkI965KAgBGe7bhJaYJhVCmFiMr
Ca9xvSLRqvZt6HcONB/kwHY39tC9SjNBfQBD8sWb81sIPOFR6AowvY4b+SF0tlTJ
JeaAgyrwU8MncE2LI7mYurkWoPvAL4uevN0r/Ai8UixYjBJ48vPOz5zH3fkPml/n
pYqlvu6ruPXOkAMAiXLOh6ZV+/jz9uK44h8kwr+blwPlb6WvIMTxjYYWBDWDdhWD
xhfvX0YIK9++MLZW+4boTgI6tlW3y5BFHUactlEb2UfY+FN49do1+L9yTX1sacfq
ausO/EGkFI3X61MhIbPvG9NnByE2R2AQAV1fuQo0Igtd9x9uddzBMi3jqoL/6Vfi
Ge4KgHED8v9c7ibYDmJpCANRkrAufsL2T5vRnTVf4UjS+qHv5dqfQf41bfveS9eE
hy+DkCwo//8uGFgmylggkAa+H2L0a8ZUcsSlRdB7q1h/iFAiKOPWMHjucKmBnAvq
/w7B9hPsPsv4uMluyFTH3DMHFzJL1XiHxt5jwHlqcN2m2iU9qGbG6HiMgrdom9uX
9ZtAU9+KMiqcbnTjpfAw5oW7tzOsAM+6jRKSZzIP0KacNacKUmKKiHqSMQpcF7yF
36gIc0+3kX3HEmVI7kdW
=pW2L
-----END PGP SIGNATURE-----

--EdjFGaXEAr61LuLmHVlr8sxX9ipGHrGa3--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
