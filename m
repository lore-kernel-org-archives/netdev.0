From: Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 02/15] usb: gadget: make config_item_type structures const
Date: Tue, 17 Oct 2017 11:30:34 +0300
Message-ID: <87r2u2jhw5.fsf@linux.intel.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com> <1508167134-6243-3-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha512; protocol="application/pgp-signature"
Cc: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, julia.lawall-L2FTfq7BK8M@public.gmane.org,
        rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        knaack.h-Mmb7MZpHnFY@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org, pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hch-jcswGhMUV9g@public.gmane.org, sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org,
        kishon-l0cyMroinI0@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org,
        jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        mfasheh-rOS7oXVqrJRBDgjK7y7TUQ@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508167134-6243-3-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi,

Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> Make these structures const as they are only passed to the const
> argument of the functions config_{group/item}_init_type_name.
>
> Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> * Changes in v2- Combine all the followup patches and the constification
> patches into a series.

I'm assuming this depends on patch 1 of the series. In that case:

Acked-by: Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEElLzh7wn96CXwjh2IzL64meEamQYFAlnlv6oACgkQzL64meEa
mQZAHBAAzevMuWnGzq3NbozQhxU/Ze7hjSKUUwpDeh5lig3COHhuUW8dbW95O5wr
pEcJCpPztIvXkmT6umC0Z+L3+ylkvRKpBRUimhe212PG7LWY4XKlQF4Jjscvs0Fg
84GPDsoYiGMrsfrZ1TLUj70y6gl4W/ft3c9FiVkxCN4F0w/a7lGYykKMBSX6WGVe
Zu7YEnSWom4D9irkkCl4gUCA31IKsCzz6JnR+S0nN7tQiKDzXIuhmCjE9UimABsm
L1nJ6fv/t5D+1SWmJg6IV3/HsoXFahjgdX0OevIZNCyVRHjSmjjOC9DNl8FU9K49
UEnm/lMrL8pEHbuGeahmKG/iuFxG3COxtY4kzHH2vJ22su/nHk8qDkBzB+cItxO0
iZ5tQhr555dQxfICJuTvg9UKcsj/oNyYuXDTUZbgX4+dKYxCJrfc8jt33gnz9z6O
1KTL6iQlhXEHS4fNgaSVktpyMzDJd3aws3i9ota2bp+zr8PSmcrXgLP20WOEKs/W
TsmCN+RCfgw9rdVro1D7cEOvMwBBoDxGzjA1MX1q61J/BVzgAd5pqE6ILQgQtmFh
6gBh0y1Pde6xDWU6J+rNXFOru21gK9iiTUA3/M2Kfci9DBk+GWtPGGV8R9ovnTzC
R6p5tT+Rtm0ns7aHybs0HsX4Zh0HsZAF/z3sps1IiMUeBdq25QI=
=q5aO
-----END PGP SIGNATURE-----
--=-=-=--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
