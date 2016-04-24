From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v5 00/21] Add HiSilicon RoCE driver
Date: Sun, 24 Apr 2016 10:44:24 +0300
Message-ID: <20160424074424.GD7974@leon.nu>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="llIrKcgUOe3dCx0c"
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linuxarm@huawei.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gongyangming@huawei.com,
	xiaokun@huawei.com, tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--llIrKcgUOe3dCx0c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Apr 23, 2016 at 06:26:38PM +0800, Lijun Ou wrote:
> The HiSilicon Network Substem is a long term evolution IP which is
> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
> Sybsystem) also has a hardware support of performing RDMA with
> RoCEE.
> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and will
> support mulitple versions of SOCs in future. This version of driver is=20
> meant to support Hip06 SoC (which confirms to RoCEEv1 hardware specificat=
ions).
> =20
> Changes v5 -> v4:

v4 -> v5

> 1. redesign the patchset for RoCE modules in order to split the huge
> patch into small patches.

Thanks,
I may admit that I didn't look on the patches yet, however two things
already spotted my attention:
1. Please fix Signed-off-by signatures to include First name, Last name
and email address.
2. Please run spelling checker on all your patches.

--llIrKcgUOe3dCx0c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXHHlYAAoJEORje4g2clinOTYP/2bO+xDp99PpL9RnexD4lu+Z
/UlXxrOtyRNmQcaWHrt8pyI87qBPQxtsUUeFTp1sm2+yTh7IouRCSk/wZGglJ2RM
ojPZ1o1Wd3czA3Dq0u2LzOotd0iyO7GWxTlmlzvk2zR8MP448OgUMq3RzfqLDZE9
2xAlpf+5bzSch54wFNTOixYgGj62fe7OuUygwVgx7UcWFdaC/KNnuu32O5H6WTmC
2grOFVUx57VfmjwAqXpPidlSYm6t6y8lB9uTPhmyuN/RGbqoHayCE6eiCCQ1S/88
JKjsCmVX0c7SEPENsMM/T1d8pJd4x7ZOzNL8SGACUPuDh4aszVJ7xtlhuvO1dwGq
xkLL2mIxB9wel4vBL3BQxJzTz+eLhvbL2aNkE3/sUVRt6sMNW5Tk5uUNNreuYlQN
CcO1ndwfVgM/GPQQQCoWTrDI9R2h719O2Gb0tBPd/0oFrZ7A7l41VZndhdlLVK78
x3AgA7QEFVOF9JdXBlqR9tMzNRnFbZbRsbhHS47tYhpC7domULnHEwnlIZFRcxa7
30iZ3aR6hv1ALw5ikQGLBZkSdwPnolZL9Qzm6wX3mNjHVNokdUL2oFKV/Bc51/M2
GkpuSQRwDAeOZhQaDYaAPxYrqyV9NJrJ/GJiRcTYHN3eMi+JDLguj04CIwbyhVgh
EFqEWxOdZIiHskCeegOR
=K1cQ
-----END PGP SIGNATURE-----

--llIrKcgUOe3dCx0c--
