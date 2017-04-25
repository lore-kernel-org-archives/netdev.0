From: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Subject: Re: [PATCH 2/2] ARM: dts: Add the ethernet and ethernet PHY to the cygnus core DT.
Date: Mon, 24 Apr 2017 17:02:07 -0700
Message-ID: <87zif5cq2o.fsf@eliezer.anholt.net>
References: <20170424215022.30382-1-eric@anholt.net> <20170424215022.30382-3-eric@anholt.net> <1759fb29-0678-0ec5-5398-16c4a3ba9660@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha512; protocol="application/pgp-signature"
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1759fb29-0678-0ec5-5398-16c4a3ba9660-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 04/24/2017 02:50 PM, Eric Anholt wrote:
>> Cygnus has a single amac controller connected to the B53 switch with 2
>> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
>> the external ethernet jacks.
>>=20
>> Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
>
> This looks fine, just a few nits on the label names:

Thanks.  I've applied all of these (and Andrew's and Scott's
suggestions), and I'll send out a new version once the DT maintainers
have had a chance to look.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlj+kf8ACgkQtdYpNtH8
nugCpA//eU13QnQlPGNi6wNZPaHcpno37X9xQzX43/9dpWwZ51tniYZg9hNEq78W
/6zboT+2hTzMhNl1aPDhWDGqzcMrspNAN/O9Bue+IqX6/pxT+IpfFkmdm8Pxtzh1
uZNXKrY0d6S1VP+CuHpsYVZe+1EoAuzbkHGciuKO70X864VdGD8J7P4GDpaKRZjf
wQYjXIi6Hda0YWXyMGrxqyyeVpZtqox/aB08t7sGhO3Qb2RQkLYlg4v5QYDM5rKu
602ajmdLiox6HZQLDDFqc+BdH6j9UkRvnOp4LIex38k+wztIklzApljnTgt4ni60
TZcCXflPXG1D+eSS9T3Ja3lp/2pJMhTBe1Fw7r8bUtyuJzD9gTbHdkrLlPOK5ien
REow8+WGM3jcttHaqxggyNNDD00sBMbCyFYGDY3vPNOC9c/CBI0rilr1yM8x/xl+
49yEvjy87IZl+5Ey/DYn6R8BeanjIN9MYzq6NkHvYqYvSo5i9NHe/UyO/gXCc54S
LzYa8RkZgWMhZixIHukJMjV7cqdKeGRax2x1pOuF2bD3k23XxHjYGE2LBUIHA6od
yEPjr1s7KuQoXijQXj/FfZb40GEaY71445O5Ls9Fjblbe5RmeB76fMx7ZrneYmQW
nL8DtPUeUlKArjHs81v0/Ql8avTz8N/tB6tlp3lJDSH/rMR3eQI=
=PLon
-----END PGP SIGNATURE-----
--=-=-=--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
