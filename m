From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v4 00/16] Add Paravirtual RDMA Driver
Date: Thu, 15 Sep 2016 10:02:33 +0300
Message-ID: <20160915070233.GP26069@leon.nu>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <20160912180251.GH5843@obsidianresearch.com>
 <BLUPR0501MB836ED564F2AE7AB9221AC25C5FF0@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160914173636.GA10309@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="b5sSX5qSQrSInIHt"
Cc: Adit Ranadive <aditr@vmware.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:53380 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759534AbcIOHDU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 03:03:20 -0400
Content-Disposition: inline
In-Reply-To: <20160914173636.GA10309@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--b5sSX5qSQrSInIHt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 14, 2016 at 11:36:36AM -0600, Jason Gunthorpe wrote:
> On Mon, Sep 12, 2016 at 10:43:00PM +0000, Adit Ranadive wrote:
> > On Mon, Sep 12, 2016 at 11:03:39 -0700, Jason Gunthorpe wrote:
> > > On Sun, Sep 11, 2016 at 09:49:10PM -0700, Adit Ranadive wrote:
> > > > [2] Libpvrdma User-level library -
> > > > http://git.openfabrics.org/?p=~aditr/libpvrdma.git;a=summary
> > >
> > > You will probably find that rdma-plumbing will be the best way to get
> > > your userspace component into the distributors.
> >
> > Hi Jason,
> >
> > Sorry I haven't paying attention to that discussion. Do you know how soon
> > distros will pick up the rdma-plumbing stuff?
>
> We desire to use this as the vehical for the userspace included with
> the 4.9 kernel.
>
> I anticipate the tree will be running by Oct 1.

+1

>
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--b5sSX5qSQrSInIHt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2keJAAoJEORje4g2clinvFQQAK11yirzsFNtZXL6DJ0OuQkV
8k//QaOX7sU8JITJG64oNdzFuOEjk49zXPbnbI57P9JtYqXTc01Tap+ZCfqXHnXb
Krvyo6Ry97F/90eUs/Kl6BBlWLDKs4g5xCUPukiHOqJWPC/w+0liFJRgWKg2c9r7
02UWza0XnslacHRaSWbPte7neR9Tz7BOdYhZPghGpLv4cw33y4EDOB/BJ383rOUx
5dGJK+w1sUlzWrK5r/Fzlpsy8AXnfH4jFfpe4ef7n5nigHzlVqexKzhYDjz0ftKA
bj7XB8Skg4YohYYP82Urm0WEG0rVRcdNphvQFqfvDMoXFHZvnpUue2m7lptk/TZ4
+V9fvVNf+2qPpfXz6LBCVgCJ9BRy6izU/uLuj6F1vJNSATa5VhO6adN6XiDW8H2Q
A6AOReoC0PVOm5RkeSCH6zm+KeOojfX7IAJLe2YA2Eu7e3jWyAtvy09mneDhjUdS
YWKpKz5U+ej/mRod+7RISaLDj67zGZp5AcgLBr/f/OCj88d9UHxyxn1cZQEvJ3Tv
/VFC9X6vn6ePGGPPmyYeCWzORuJ3jvaOhhIb19kp2QrNykHdnP+qM9HIKOnt5fio
WoLcqvaOlc7i9SOrT8842MoZFjz68hvmRqJv1bPd0zgUjZgmxYWUoQiKAB5QE3JS
UaQQN3SjNJYWX8t6C4q0
=xROE
-----END PGP SIGNATURE-----

--b5sSX5qSQrSInIHt--
