From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 13:56:39 -0500
Message-ID: <4B311667.5080405@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <4B3115C1.4070303@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6C7BEE90DCC1CF66CE90B145"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:60194 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659AbZLVS4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 13:56:43 -0500
In-Reply-To: <4B3115C1.4070303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6C7BEE90DCC1CF66CE90B145
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/22/09 1:53 PM, Avi Kivity wrote:
> On 12/22/2009 07:36 PM, Gregory Haskins wrote:
>>
>>> Gregory, it would be nice if you worked _much_ harder with the KVM fo=
lks
>>> before giving up.
>>>     =20
>> I think the 5+ months that I politely tried to convince the KVM folks
>> that this was a good idea was pretty generous of my employer.  The KVM=

>> maintainers have ultimately made it clear they are not interested in
>> directly supporting this concept (which is their prerogative), but are=

>> perhaps willing to support the peripheral logic needed to allow it to
>> easily interface with KVM.  I can accept that, and thus AlacrityVM was=

>> born.
>>   =20
>=20
> Review pointed out locking issues with xinterface which I have not seen=

> addressed.  I asked why the irqfd/ioeventfd mechanisms are insufficient=
,
> and you did not reply.
>=20

Yes, I understand.  I've been too busy to rework the code for an
upstream push.  I will certainly address those questions when I make the
next attempt, but they weren't relevant to the guest side.


--------------enig6C7BEE90DCC1CF66CE90B145
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksxFmcACgkQP5K2CMvXmqG/FQCbBrkWYeSsy/McAXgIeunEVht6
wdUAn2yXf163nKyYkPWFt3orqnFbSwBr
=+fMG
-----END PGP SIGNATURE-----

--------------enig6C7BEE90DCC1CF66CE90B145--
