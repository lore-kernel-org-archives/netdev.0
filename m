From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 13:17:28 -0500
Message-ID: <4B325EB8.4080300@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org>	 <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com>	 <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>	 <20091223101340.GC20539@basil.fritz.box> <4B31EF65.6070000@redhat.com>	 <20091223121431.GF20539@basil.fritz.box> <1261590740.19822.94.camel@hermosa>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig08A5785F1ABF09E4A31AB908"
Cc: Andi Kleen <andi@firstfloor.org>, Avi Kivity <avi@redhat.com>,
	kvm@vger.kernel.org,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Peter W. Morreale" <pmorreale@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:7306 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755271AbZLWSRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 13:17:32 -0500
In-Reply-To: <1261590740.19822.94.camel@hermosa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig08A5785F1ABF09E4A31AB908
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/23/09 12:52 PM, Peter W. Morreale wrote:
> On Wed, 2009-12-23 at 13:14 +0100, Andi Kleen wrote:
>>> http://www.redhat.com/f/pdf/summit/cwright_11_open_source_virt.pdf
>>>
>>> See slide 32.  This is without vhost-net.
>>
>> Thanks. Do you also have latency numbers?
>>
>> It seems like there's definitely still potential for improvement
>> with messages <4K. But for the large messages they indeed=20
>> look rather good.
>>
>> It's unclear what message size the Alacrity numbers used, but I presum=
e
>> it was rather large.
>>
>=20
> No.  It was 1500.  Please see:=20
>=20
> http://developer.novell.com/wiki/index.php/AlacrityVM/Results
>=20

Note: 1500 was the L2 MTU, not necessarily the L3/L4 size which was
probably much larger (though I do not recall what exactly atm).

-Greg



--------------enig08A5785F1ABF09E4A31AB908
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksyXrgACgkQP5K2CMvXmqHLTACgi0LH4j7MTQF26kIK4xN88fMs
7ToAn299TTxq+wq438HfzIUHsLofU93G
=V5fw
-----END PGP SIGNATURE-----

--------------enig08A5785F1ABF09E4A31AB908--
