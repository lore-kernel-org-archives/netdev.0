From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool] ethtool: Correct register dump offsets for Intel
 82575 chipsets.
Date: Thu, 12 Jan 2012 06:35:34 -0800
Message-ID: <1326378934.2709.64.camel@jtkirshe-mobl>
References: <1324636371-5402-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1326373862.2709.63.camel@jtkirshe-mobl> <1326377284.2819.7.camel@deadeye>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-JtZSmtNwAdPv3AHF6Sdp"
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54719 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751958Ab2ALOff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jan 2012 09:35:35 -0500
In-Reply-To: <1326377284.2819.7.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JtZSmtNwAdPv3AHF6Sdp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-01-12 at 14:08 +0000, Ben Hutchings wrote:
> On Thu, 2012-01-12 at 05:11 -0800, Jeff Kirsher wrote:
> > On Fri, 2011-12-23 at 02:32 -0800, Kirsher, Jeffrey T wrote:
> > > From: Matthew Vick <matthew.vick@intel.com>
> > >=20
> > > When support was added to dump the registers on 82575 chipset devices=
,
> > > six register offsets (receive/transmit desc length, head, and tail)
> > > were incorrectly mapped. This patch remaps the offsets to the correct
> > > registers.
> [...]
> > Ben, what is the status of this patch?
>=20
> The status is 'arrived just as I went on vacation, and forgotten'.

:)

>=20
> I'll be sure to apply this before releasing ethtool 3.2.

Thanks Ben!



--=-JtZSmtNwAdPv3AHF6Sdp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPDu+2AAoJEOVv75VaS+3O238P/1+/+Bo+MqoVUPnDZQEk3WIP
eZ2yAIjhlVNHAX7yUFJs2yc2aH9PyhsrIUyaZZW3A2I71cy05z/PhPZPhpaiuxaV
Lhw1nWkUsjdlV0RKJGrE8+hcA3dS4ECkOdT1KaND4AxmG2lEQ0yqMb3VlY+htlhK
qlRwOkIbXh+S6Li8IXcXJQqKkQtocLO4jRIqsXh35bTWud7NweKR7FAbdvE1iv6K
RDwtgWJmejU7yHnsnCF4PrunznXsPay66UTdkVhhjUut35pGMUCOOjmKsId4dcHZ
dZZE/1eaDTaBOE5PISZKOzha8dpEsvbe2qftNqQgySc8CL8CNxvt55XG8Tq2Log1
JwZ91m3r+86Q0USEDKqKPdt1uRUfXvZZ0rXzuMWAXBw9MHcjYVuLEwRQuvudKFgq
JVYrzS/+jKEg+D5pAB1sJ/WNQNxgPqipGp63fc+wiI0XG6f2U4QcXo+yQwsQgt33
ar9Rxv8WZBqfziWSB49MbQle3gxnbvPajvBC11t0RejsCvSyKmOVbNIvc0f+IERA
7XReYSriRK3l0UnifHcOshDSKr4u/C8XgQxGmmZNWCviL1YbQS7IezRfhROs3a9s
sOMlk8XCfdjhforZ1PIQsQtzTut7Jz4raugeH24tdhRRyX79EtSJFIb3JoB0KoX/
G2aOp1sxmtPZRkCKi4tD
=H0o/
-----END PGP SIGNATURE-----

--=-JtZSmtNwAdPv3AHF6Sdp--
