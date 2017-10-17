From: Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 07/15] usb: gadget: configfs: make config_item_type const
Date: Tue, 17 Oct 2017 11:31:17 +0300
Message-ID: <87o9p6jhuy.fsf@linux.intel.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com> <1508167134-6243-8-git-send-email-bhumirks@gmail.com>
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
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508167134-6243-8-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Make config_item_type structures const as they are either passed to a
> function having the argument as const or stored in the const "ci_type"
> field of a config_item structure.
>
> Done using Coccinelle.
>
> Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEElLzh7wn96CXwjh2IzL64meEamQYFAlnlv9UACgkQzL64meEa
mQZQhg//Us3sJZUbfVmsAmf2IlBuez8wGH2V7mJtJCLYzgENwMbLQvD7E1nHjCTt
JkiH+zAtEB0xnD7/ZvUqxQTaZdiRQfw059PEzq7fntUcNiO6KhqiSuIpLKO/YyQq
dMrn13XN17iEC+ubTVquSnoi1h2s4UsUL5jlvFlYGIpuq3SW3rSqJkJDe6McTpgJ
nlNCRxF09UctuKVczbjurXyaJ7UmzXDxSyLJHBADq+jpByqpOBfcYEho3oEfsroc
7dd80z4cywzRJQ/Udho/AZ72qj18yWZvekBpHS9bUzLOUx8yDN7V20XTdmyeVtcg
0vxqraf7VNWQy82o32ptA2EfvfQ2j4GV5Kz3eYzapMF85qmarjAqlUwhtyKE2oiX
C6Udsm7h44322k7dmLQB8ZS8K/iVfYcgeOnr5koGw5ze7h2ajaAW8kADreVfeM52
NR+nBkC20gYUROtDe99YyJ3FnOwKrh5l4L6fT8qXBiaXN0QPotY98QROMAX3i3zl
62kOmbAnCjuxei/y5cApsuo874PSEz6lCOMa0hkvothqbS+kpq9dQQuI5EfSsAKu
jR46aG1rpMGlZNPWVzF+DaNaGat5CmbO4Y8LkbN4sU7qSunNkSbd4YgBB0pj9Dg6
52MwP7kUgqLasgz5fVvn9YXCIcqcEXWXsUADJh8+DrQkjXnOs+g=
=nx9P
-----END PGP SIGNATURE-----
--=-=-=--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
