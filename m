From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 00/16] Mellanox, mlx5 RDMA net device support
Date: Thu, 20 Apr 2017 21:49:55 +0300
Message-ID: <20170420184955.GU14088@mtr-leonro.local>
References: <20170413033706.19016-1-saeedm@mellanox.com>
 <20170417.110851.1496380796999919507.davem@davemloft.net>
 <1492713677.3041.3.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="brdEIFGMNIjz5YJG"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1492713677.3041.3.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--brdEIFGMNIjz5YJG
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 20, 2017 at 02:41:17PM -0400, Doug Ledford wrote:
> On Mon, 2017-04-17 at 11:08 -0400, David Miller wrote:
> > From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > Date: Thu, 13 Apr 2017 06:36:50 +0300
> >
> > > This series provides the lower level mlx5 support of RDMA netdevice
> > > creation API [1] suggested and introduced by Intel's HFI OPA VNIC
> > > netdevice driver [2], to enable IPoIB mlx5 RDMA netdevice creation.
> >
> > Series applied to net-next.
>
> I've pulled Dave's net-next into a branch in my tree for the IPoIB
> patches to go on top of so that way it can hold the final touchup patch
> without any conflicts anywhere.

Thanks,

How and when do you want us to forward it?

Thanks

>
> --
> Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> =A0 =A0 GPG KeyID: B826A3330E572FDD
> =A0 =A0
> Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =A01274 B826 A333 0E57 2FDD
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--brdEIFGMNIjz5YJG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlj5AtMACgkQ5GN7iDZy
WKdIYw/6A1xAer+4I8ynrZiYtIuWmal+LB3PsjXB04wgCfVISijbnUgDiflPber5
HpL0KNecmiVUogsvbk+Fww5cHV80tjhYJV3sVoaPlo9E8Ra5+dtAj7iZ4opua0Yc
/X0Rvd9OUl3qB7yFV4ZcZazb+PAYXPBratqhcpAE3iXSsCeXXQx+c84NNvdIr2f9
GrJiSu3sK+g1x28DxkEiqp4HihtH9JEsutJNKQnIGN4Z6KPjQovZpNWhrfpd+lkn
2JLXXf0nc27akOcXmbXMj0NOGIJ+p6JSnb2FqBtfSncPqQgQsEzjzQcXWKMemiHH
wEQdQ3BNM1f5GU7IWKaxd7mYkMKGTw4uqsXoa9lBfHDR/aBfMVdlbWsdb00guPZM
Xx2M5T3TRVY2vbAOq1ZRRhlL6NrOtPQd7ingjbDsPGGKPs58e3TfdPiB+OOh6e07
Pxe5D8437rdvc1YcUzVP94edKr5Dvwu4yh2EJTUr7OBpke2w14zDeNgPpSVugwz/
WJSdEhnnMTXzU1XtqT4zuBRBGqMn3TZ9cNGhEwMKY3MNj93zOXVFZ9PW2/PvaQXt
V0/nSSUQ52bsi2En5f0JRarqOqN2+cv5iqsuv/L2lYl+VzxAqMiyr6skK+mz5yHH
cbIpTPb2Yw+Gc063vpxJDN5FUHN8V6ToilPI24eEOIGoJ8+Jsa4=
=md8b
-----END PGP SIGNATURE-----

--brdEIFGMNIjz5YJG--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
