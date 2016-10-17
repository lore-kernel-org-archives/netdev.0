From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH V3 RFC 2/2] ixgbe: ixgbe_atr() compute
 l4_proto only if non-paged data has network/transport headers
Date: Mon, 17 Oct 2016 15:48:40 -0700
Message-ID: <1476744520.2326.54.camel@intel.com>
References: <cover.1476737917.git.sowmini.varadhan@oracle.com>
         <07bf787b2a346e12ca6e57edaf1a3025de9ae5dc.1476737917.git.sowmini.varadhan@oracle.com>
         <CAKgT0Ue7HL4CWdF2jBzLYOqXuO2=J9GeF79qfcdOWB7+cA0_3Q@mail.gmail.com>
         <1476743871.2326.52.camel@intel.com> <20161017224702.GA17588@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-9+mx2nRGZsSSm7mo3aqN"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41062 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755138AbcJQWsn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 18:48:43 -0400
In-Reply-To: <20161017224702.GA17588@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9+mx2nRGZsSSm7mo3aqN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-10-17 at 18:47 -0400, Sowmini Varadhan wrote:
> On (10/17/16 15:37), Jeff Kirsher wrote:
> > > Reviewed-by: Alexander Duyck <alexander.h.duyck@intel.com>
> >=C2=A0
> > Sowmini, can you re-submit this to intel-wired-lan but without the RFC
> in
> > the title?
>=20
> V4 resubmitted.. I think I just inadvertently forgot to add Alex as the
> reviewed-by.. could you please fix that (or I can resubmit v5 if needed).

No need to resubmit, I can make sure Alex's reviewed-by gets added.
--=-9+mx2nRGZsSSm7mo3aqN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYBVVIAAoJEOVv75VaS+3OO/0QAJDMU+UwbZfpE5PwyHg0GA5p
r9UDbqjLZRTLHZAyq5jkuCZRen6a63hklLr6h//t7Emmrkj1IiF5dGPVFFguFlMD
LGLi7ZzMMkUIyRXrRPJ2bDV538jj7NPRmHVJkC+3SdUqhH0zYX0wE8HJdlPZNor/
MtZs6QEQRj3q8f0rtDURnNDrYmuvJb48rskgG/ZBlW1S4IcUwI8nXXKKezDNeu3o
W9yACZB34f7Z6xUWMT/2aSDtzz0xijMWbW/Tz8MIE2qmgDbF+5NEv70ZPtp2f+Dv
rnTUEM6/qhZ3Tmoypw5N1l5kc3Ej9dD+Xt85RcMjLMCGeRQthkBPi7LWgbjZmHRF
2CeJg/3YNV4QkMgqrR97V6q22vGKOQS/TS+zGz9nTHaJX022UeQ+sISHVI6Qabo1
Ixg0rAS1WrmdWrimIBZ/vi7Lk07zizju39i12lN4A4PgGCG9QqADjX46ynDgF0h4
t0uxTDHdvttbqSu8bMo3/K0UcWUZLPQdqPAo5Xk346PUjZt3RLBk3UFqyX/zUYWO
S5WCfM62SAdF2zo9TRLKJQLygUOZSArGnp5RhrNwFYm5vTjV2Yua/B8c664W7A41
8rNbkp9Y4EDCI4t5Wers8NqBa1z1X7OSIXzk0DzZuGk+njfOp9I73ETaZGcMlGuw
LLM24FvbehDo/CivOOOZ
=zSOy
-----END PGP SIGNATURE-----

--=-9+mx2nRGZsSSm7mo3aqN--
