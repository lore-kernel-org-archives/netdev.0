From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool] ethtool: Add ntuple to the -K option in the man page.
Date: Thu, 19 Jan 2012 22:35:42 -0800
Message-ID: <1327041342.2707.42.camel@jtkirshe-mobl>
References: <1327040031-19152-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3hap4Lh4LVg/+0U+2D6N"
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net, Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37817 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825Ab2ATGfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 01:35:43 -0500
In-Reply-To: <1327040031-19152-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3hap4Lh4LVg/+0U+2D6N
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-01-19 at 22:13 -0800, Jeff Kirsher wrote:
> From: Amir Hanania <amir.hanania@intel.com>
>=20
> Signed-off-by: Amir Hanania <amir.hanania@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  ethtool.8.in |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/ethtool.8.in b/ethtool.8.in
> index e6e46cc..9b8c5bc 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -212,6 +212,7 @@ ethtool \- query or control network driver and hardwa=
re settings
>  .B2 gso on off
>  .B2 gro on off
>  .B2 lro on off
> +.B2 ntuple on off
>  .B2 rxvlan on off
>  .B2 txvlan on off
>  .B2 rxhash on off

Sorry, I meant to send this to Ben as well.

--=-3hap4Lh4LVg/+0U+2D6N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPGQs+AAoJEOVv75VaS+3ONRYQAIrkEqLrCgpSP+Bsh88mhRlh
TDmH/Tfwu2ujXOogRaPK90/6NTlPSw9fCSQ+qMu9nPLz4ugLiFr5coVhUveu2U7G
gybdEcGYOialXA5fPUIop9IXopONjkC9l/CBLMwIF9Y9T7Zu4EBRvpVtfO922jUS
U6C4DayoX8ib0acORhhQ/Mjw4auwBhaUlnllSsWAgPNy1FYCx5XvaU+eKguJUO/4
k01Z9A61O+O3L4CUS8MOxuqO70KGEUVfEzhJ9CK2T2DjtVofgJSWhWwHGnnYnKrw
V/9CFgHRyYUTl0PkrbAoAXbLSGYfU+m6tq+fmPM/hnpGjIwVk2KRzBuIChYb4qi9
XynTE9BprsMs2b9EUTOQt4VA0PkkuPvF9vF77IsZr/ixgtvkSPfI/bf2Z9PlZomv
/oLvxxho23Fc3xSEAuCeFYI/d762Hg1sg1GtG/rMmKcXaFEXjR8Ao5vrwrYAZw9l
dOqkIdraG6VV30An69RG+2g7Ew+Y8Om/myIo8xH49241lRoDYBWE7wF2ObRNrIIZ
A3NG55DTm4xRrsXhnrGot/t3n8j5DeImoanAdPOAQqPyn6nMsRN5FhfVSyDcnZyS
ZiafM4Hdo0A4W0zr9p0dHhB1yse8AQCs+wOF9wi2yP+Lk1nNPQvuOrQA8eXEtViV
nHtST9/gH9o8axx+ByN0
=xNgI
-----END PGP SIGNATURE-----

--=-3hap4Lh4LVg/+0U+2D6N--
