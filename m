From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sat, 03 May 2008 14:38:01 +0200
Message-ID: <1209818282.3987.23.camel@johannes.berg>
References: <20080501.024320.212547875.davem@davemloft.net>
	 <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
	 <20080501.034950.261408566.davem@davemloft.net>
	 <20080501.035335.216935614.davem@davemloft.net>
	 <1209639500.7067.0.camel@johannes.berg>
	 <20080501110341.GD7490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-2MBmCFTkYWKaSIOdYB2Q"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080501110341.GD7490-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-2MBmCFTkYWKaSIOdYB2Q
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-05-01 at 19:03 +0800, Herbert Xu wrote:
> On Thu, May 01, 2008 at 12:58:20PM +0200, Johannes Berg wrote:
> >
> > Indeed. But then why did we never see this bug w/o monitor interfaces
> > and this reinjection?
>=20
> The debugging only catches it if the expanded area actually
> gets used, e.g., by skb_push.

Why, btw? It's not too hard to check the allocated size, no?

johannes

--=-2MBmCFTkYWKaSIOdYB2Q
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBxcqKVg1VMiehFYAQItkBAAiJJrEPIsnAgHMNPZuR3cSlh1T1H7mKsb
Lk5C3Vz4fQsOqJ6grNCFxPtBtRxDuPoIHMWuB7/7rGIWhTALRtW/pBugQ6FWRiw+
mhPYp+nbp4HijcbfZkPzGPNzCf74u53DQ6rg043LfIEfN2cKPZ9QkFOJlXcEddgG
ujE9J9WGDCuMrfKCRM8BdHrcUC6iUtYJbcuj0Cq9zN05XzN3QkxqmFsSAsiVLFyC
ciLkp+yLhcbzm5h0Ao2b3zPlmFbi/RNWQKLy0QQcDL/pmHdnyRdrLzh5KsslguDg
AftF89hvV9ixl6DW/gCzj/iRClYsjGEoaHjO6FSgqpx61MfWbAnsGE71JSu3uPJx
qaKr76tZQX2Q77mWd9URpiB7WSqDbMoA1wiZGeS6iaJInbDZl/OVYgnNOZstVg9i
FyHB6tz+g480gIN94zFjItOi9lXjm4qDLkNrADUvkS+d+aOZL9f5MGFKEWggeNDN
VNHAO+GPw+1UrS53kveebCsCw90hd+JfbDuv1KpTUCAou9S1Jl/XSQb+9NpF3RxC
cpYvRVZGGuB/4jiNVrpkOtg2JrYJcK+RwYuoBNoOc+CzYU7hLhsK1hko2Nyvo4mf
ArzOz+tKNVXaLSameVXfxkKhJHiBKur07LWhGtP2cvaYF5jEFeDDmTI/4G8jRnoy
Xnh7FWF6t4A=
=5ov6
-----END PGP SIGNATURE-----

--=-2MBmCFTkYWKaSIOdYB2Q--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
