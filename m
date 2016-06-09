From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v9 08/22] IB/hns: Add icm support
Date: Thu, 9 Jun 2016 09:58:17 +0300
Message-ID: <20160609065817.GP3663@leon.nu>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
 <1464795484-77395-9-git-send-email-oulijun@huawei.com>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="e2bLSPRkEYxxSNev"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1464795484-77395-9-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--e2bLSPRkEYxxSNev
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 01, 2016 at 11:37:50PM +0800, Lijun Ou wrote:
> This patch mainly added icm support for RoCE. It initializes icm
> which managers the relative memory blocks for RoCE. The data
> structures of RoCE will be located in it. For example, CQ table,
> QP table and MTPT table so on.

I wonder if you have the same needs for ICM as it is in mlx4 device.
Do you have firmware?

Thanks

--e2bLSPRkEYxxSNev
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXWROJAAoJEORje4g2clinai8P/2NpOvkWOdQ3mtkNX11Z2Oyq
mzbsAw5DCltPnrZAWcaEEiaZcFp//RqDRKF6sIkvgDr+5lChdRzosOntFUoXLiBC
AqVsUffyMGjhQFepUaPDdsk3gjizdV8mxgk+tuPtkKPY1DZHPJ2mZOIvikSwsDi3
dcLTmykGO5u5o7cVopviSiPXhVXUJ7px9PveN6qyYL4P2hOrwARQnwyS6eyYEDDC
7JXwjhsessneQ03lhRwXnne04u/6i+lhvG7M0TfQWjnXgjvKC3cEHzGf0HAjiabS
uRCKB4xZF1FWw2iQNhKOaL6Z3gawg2Cy98Auh2XuFJhdsds0Ro/f7QD9JPlGMtxx
nvEjXcxouehJRkDA2YM7KCYqyeYj6MPmSyw3FWAv9YTx4zKLsFgcZz1W0+LBq6bK
cmNxNc79Nuz/5FprbuvVzZoe39FbEs4B5uUM7mDH4iYLOMWIZvMl+8SOgxYFzul9
/bnh0jVOM3E64FkFzFDYQ0nxgH3AZcLNlmi40z9dV0a3wxLM1srtMwpOCR4ElfED
EbXmz8fBuxRrRo8BC+6RitB7Bsf/mDQY6eLrOcgLPRz8VsRhnvcO9EjHnbyUpVOf
1GC8aUYoUOIsHOM/rXFR1DCo6tpdXvo64yIew9iCDDxYUDQrzGrRiNqJw7DnuGon
+SEuFj4nKEeQQIDCsoW+
=pZNH
-----END PGP SIGNATURE-----

--e2bLSPRkEYxxSNev--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
