From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 15:35:06 -0400
Message-ID: <4A89B0EA.3030605@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A87C3B9.2040206@redhat.com> <4A896648.9040707@gmail.com> <4A897057.2050504@redhat.com> <4A8972C3.30202@gmail.com> <20090817151449.GA19384@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5900680D1D8572290F7DA327"
Cc: Avi Kivity <avi@redhat.com>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f205.google.com ([209.85.217.205]:47834 "EHLO
	mail-gx0-f205.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701AbZHQTfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 15:35:12 -0400
In-Reply-To: <20090817151449.GA19384@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5900680D1D8572290F7DA327
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Ingo Molnar wrote:
> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
>=20
>> Avi Kivity wrote:
>>> On 08/17/2009 05:16 PM, Gregory Haskins wrote:
>>>>> My opinion is that this is a duplication of effort and we'd be bett=
er
>>>>> off if everyone contributed to enhancing virtio, which already has
>>>>> widely deployed guest drivers and non-Linux guest support.
>>>>>
>>>>> It may have merit if it is proven that it is technically superior t=
o
>>>>> virtio (and I don't mean some benchmark in some point in time; I me=
an
>>>>> design wise).  So far I haven't seen any indications that it is.
>>>>>
>>>>>     =20
>>>> The design is very different, so hopefully I can start to convince y=
ou
>>>> why it might be interesting.
>>>>   =20
>>> We've been through this before I believe.  If you can point out=20
>>> specific differences that make venet outperform virtio-net I'll=20
>>> be glad to hear (and steal) them though.
>> You sure know how to convince someone to collaborate with you, eh?
>>
>> Unforunately, i've answered that question numerous times, but it=20
>> apparently falls on deaf ears.
>=20
> I'm trying to find the relevant discussion. The link you gave in the=20
> previous mail:
>=20
>   http://lkml.org/lkml/2009/4/21/408
>=20
> does not offer any design analysis of vbus versus virtio, and why=20
> the only fix to virtio is vbus. It offers a comparison and a blanket=20
> statement that vbus is superior but no arguments.
>=20
> (If you've already explained in a past thread then please give me an=20
> URL to that reply if possible, or forward me that prior reply.=20
> Thanks!)


Sorry, it was a series of long threads from quite a while back.  I will
see if I can find some references, but it might be easier to just start
fresh (see the last reply I sent).

Kind Regards,
-Greg


--------------enig5900680D1D8572290F7DA327
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqJsOoACgkQP5K2CMvXmqEO/gCdHt1q+HVUVeZV00Ysot2anW61
Rg8An2YKBPCo9DLyM7/OegsLTv5hdWEe
=309v
-----END PGP SIGNATURE-----

--------------enig5900680D1D8572290F7DA327--
