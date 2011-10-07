From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [net-next] cs89x0: Move the driver into the Cirrus dir
Date: Fri, 07 Oct 2011 00:21:40 -0700
Message-ID: <4E8EA884.9040608@gmail.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com> <1317971926-23145-2-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigC6F5444F9228A9C789BB3F2E"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Russell Nelson <nelson@crynwr.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6613 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab1JGHVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:21:42 -0400
In-Reply-To: <1317971926-23145-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC6F5444F9228A9C789BB3F2E
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/07/2011 12:18 AM, Jeff Kirsher wrote:
> The cs89x0 driver was initial placed in the apple/ when it
> should have been placed in the cirrus/.  This resolves the
> issue by moving the dirver and fixing up the respective
> Kconfig(s) and Makefile(s).
>
> Thanks to Sascha for reporting the issue.
>
> CC: Russell Nelson <nelson@crynwr.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> Reported-by: Sascha Hauer <s.hauer@pengutronix.de>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Sorry, I did not mean to send this out a second time.


--------------enigC6F5444F9228A9C789BB3F2E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJOjqiFAAoJEOVv75VaS+3OS3gP/AwssDIn2l/WrGIiz7Clii5s
cqxQFsj37orH9kYEhMi1VeaDMw55uaQefpT+6h6t0a+LWkcx0aZYUBfTRhhSl2jq
/W5Z8oKk/vUwZq38GUJWFSc/i7j/MHfa7x+V3qUxEbvIyzUi1xmeLI8zWi6y8qV6
7Cm2MCmEtHZsZNqq2is+eZkbXE+BG44XQj+Owxfv1jjMMTqpJGJQCmi8ci1skPSp
m+ecv6nVEl/AeFAR7CklM3hwFDwZvaPGKbJKhOjTBm1bAPgGoPTp+W5XMYQI3V8w
baTZ7mAhgY336Hy0l3koEMyL16DXHFfbqBN7SSjI5St9mmJxxrSprdEwM/iKvNQF
30NjGIs6bntQ9lEATp1XWHnw8nNL88T7y/BGa0fbIsazfJRVIe9MeT2YJ0cbgxUn
/c4erNlnAq4U08M5Nvq6zvhHDa5FcSi4PkXsZuiYcPbQvEzawlEzHGziAh2lteCI
LSLNoshDVDls0wnYssZ0DT42GsVa8NSfm7Ix+ndh/93PS7C0Nsxc5wNVjt3OzrAd
hlsbB0Coth5yiWg2goGZhzZ81LW/4Twugb2FNYMAO6yj0CV1e/AE4tb7sHqRDEMt
7AGs573NPunNL0bSSoSRHqzvbMt5aQ4c3olsq5Yc1ZR52YVsF6lYSOCz5bXMMPwG
YbG9o1YEvdqyTY4yhtOd
=NdEO
-----END PGP SIGNATURE-----

--------------enigC6F5444F9228A9C789BB3F2E--
