From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for-next V2 00/11] Mellanox mlx5 core and ODP updates
 2017-01-01
Date: Tue, 3 Jan 2017 09:23:44 +0200
Message-ID: <20170103072344.GF12077@mtr-leonro.local>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
 <20170102.155341.1496970446718890403.davem@davemloft.net>
 <CALzJLG9ZBRMOVqFsTypCLV6Rrek8a9g43z0spvVKeku6WdWCTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="C+ts3FVlLX8+P6JN"
Cc: David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org, ilyal@mellanox.com,
        artemyko@mellanox.com
To: Doug Ledford <dledford@redhat.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:47194 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751873AbdACHXk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 02:23:40 -0500
Content-Disposition: inline
In-Reply-To: <CALzJLG9ZBRMOVqFsTypCLV6Rrek8a9g43z0spvVKeku6WdWCTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--C+ts3FVlLX8+P6JN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jan 03, 2017 at 01:30:16AM +0200, Saeed Mahameed wrote:
> On Mon, Jan 2, 2017 at 10:53 PM, David Miller <davem@davemloft.net> wrote:
> > From: Saeed Mahameed <saeedm@mellanox.com>
> > Date: Mon,  2 Jan 2017 11:37:37 +0200
> >
> >> The following eleven patches mainly come from Artemy Kovalyov
> >> who expanded mlx5 on-demand-paging (ODP) support. In addition
> >> there are three cleanup patches which don't change any functionality,
> >> but are needed to align codebase prior accepting other patches.
> >
> > Series applied to net-next, thanks.
>
> Whoops,
>
> This series was meant as a pull request, you can blame it on me I
> kinda messed up the V2 title.
> Doug will have to pull same patches later, will this produce a
> conflict on merge window ?

Yes, but it can be easily avoided.

Doug,

We have another pull request to send and we will base its code on the
Dave's tree instead of Linus's rc tag. In such way, you will have the
same commits as Dave and won't have merge failures.

Please don't apply manually this specific patchset.

Sorry for the inconvenience.

Thanks.

>
> Sorry for the confusion.

--C+ts3FVlLX8+P6JN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhrUYAACgkQ5GN7iDZy
WKfT3Q/9Hjg3mFd20GFop0r4UxSRny9c00sOYh5e54M7mOimGFP5p1OIFaO9S9dw
KxJSI7+1ChD5McQddKcWk/iR2QZNXpBoDj0OmVFV+xSLa5RFfXLn6LTfcIA+0kwe
WVIMmpY3d0oZyHSbrLUqU0Tnl21/RTZJD/I6RuoafSQk5vmk6g3+yskfPk76CVUX
5EfZ+l7GcE8erZSx9jbsH37eGIvBag9bsiDxaAo92NbZUCEUon85vFxVQzDo3ikh
ydTJuGuv8s1IoXd6kcDlbyc/bnWZOxCGeXBm7dnZ+ZT8kOUSi+CmR8hVqYB4cUhF
dv6RyrOwe0pTh2JREfRlXriRYZPAYQoDRt98012pQmjvZZ1tY/V0Rxt24JnV0RoK
Ki2rN6MncaMsOUYxmgHuCSlmS98Z9g65WlN2YV6yaFQE0otq/MCsRuQmNTPEfLlK
j4p46RdGKOmoCb+7ar2BAQ9btmHimq03nAwwti8+EMw6M9FDhoDoG9l9Uy+ca4fi
IDbHeQso0KGwkmgleQmI+tujNcMPheCtRy7OmycbiTiqooh3lwGBY8Jkk4kuCRWs
xuw6wSedEu7DwfRj1vD27p2S/zdhX1vTjzc5D3EV1FnlcUIXcJEQ1EWoQlU5jFZB
dbkei2vtVoQlKePoBpO7kXWu5JIIwD/XeyGQMQKOwOTivoCGsF4=
=PDGL
-----END PGP SIGNATURE-----

--C+ts3FVlLX8+P6JN--
