From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v6 00/21] Add HiSilicon RoCE driver
Date: Tue, 3 May 2016 21:48:34 +0300
Message-ID: <20160503184834.GD29160@leon.nu>
References: <1461845396-61306-1-git-send-email-oulijun@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zS7rBR6csb6tI2e1"
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461845396-61306-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zS7rBR6csb6tI2e1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 28, 2016 at 08:09:35PM +0800, Lijun Ou wrote:
> The HiSilicon Network Substem is a long term evolution IP which is
> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
> Sybsystem) also has a hardware support of performing RDMA with
> RoCEE.
> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
> will support mulitple versions of SOCs in future. This version of driver
> is meant to support Hip06 SoC(which confirms to RoCEEv1 hardware
> specifications).

Please read Dave's comment [1], it is valuable for your code as
well.

* Please use 'bool' and "true/false"

[1] http://marc.info/?l=linux-rdma&m=146229367301442&w=2

Thanks

--zS7rBR6csb6tI2e1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXKPKCAAoJEORje4g2clin5ScP/RyorMwW3d+j73rBd05sdKXm
zq3bk0UNB7g19Ke3ZJ9L1D1d0gU6E2hLEN3+7rdtZQNBCz7TNiQhav5y7D0AvkRV
xzHKSyd6p0uTpRayyqJzCyxNi6ZSYayzkkpKawjq+c+72lZ6Cyb2+pjw2hMeL1ul
+Wo8g4c7NqlDaubUR0JQ1WlxyIp2Z9DA8NZQjBJjF6gTQ0Ii8YjOtOPMMaFUg0ir
w7c6EgdChJApjSEk5jO+fTtNbzXvRuP8O6fslAFp/R9v9u5nhvsTEbg+Gs+zPkpU
N2JETswEJ6rrNS4p4Kz3IimFOrhWJVf/J5j29uGflkKvpW5YmorHXpicyJ4g8oVz
3yHP4O4R3N0AclrHRPIzOon0CVLrakXpvP/f2jZc7SaF5JUMvnVwFqJyK1BuQ31T
w8p5FiZqMl/vU7vI3PEJedZubXWw1xTRrFv3MsxIUybnX1qnwnochgvb7wKqdPwB
V/Q4DN3xnXJX4H7mrU/rXtbia8U/I7GRP/3NfFvohqwkhKdkYKMFvnfRdJ1ezFZj
kiWQkr68bsdh1x3QrLi6YMoW6rwEMC+iz2vN230VbycqLlA29smdyj2uW9IcLmZR
vxp+8EV01n6MoNrio/14/IBvl6coJGTue0JvvwH7x/w6DvNUt9NBkIq/+hnqj8j9
GyIHGLJqmRD7z3aZHojY
=xhCx
-----END PGP SIGNATURE-----

--zS7rBR6csb6tI2e1--
