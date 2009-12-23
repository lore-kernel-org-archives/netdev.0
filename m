From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 12:17:48 -0500
Message-ID: <4B3250BC.50203@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <20091223171052.GI20539@basil.fritz.box>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEC53A75968A6BAF3713BE6EE"
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753982AbZLWRR4@vger.kernel.org>
In-Reply-To: <20091223171052.GI20539@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEC53A75968A6BAF3713BE6EE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/23/09 12:10 PM, Andi Kleen wrote:
>> And its moot, anyway, as I have already retracted my one outstanding
>> pull request based on Linus' observation.  So at this time, I am not
>> advocating _anything_ for upstream inclusion.  And I am contemplating
>> _never_ doing so again.  It's not worth _this_.
>=20
> That certainly sounds like the wrong reaction. Out of tree drivers
> are typically a pain to use.

Well, to Linus' point, it shouldn't go in until a critical mass of users
have expressed desire to see it in tree, which seems reasonable to me.
For the admittedly small group that are using it today, modern tools
like the opensuse-build-service ease the deployment as a KMP, so that
can suffice for now.  Its actually what most of the alacrityvm community
uses today anyway (as opposed to using a merged tree in the guest)

>=20
> And upstream submission is not always like this!

I would think the process would come to a grinding halt if it were ;)

Thanks Andi,
-Greg



--------------enigEC53A75968A6BAF3713BE6EE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksyULwACgkQP5K2CMvXmqG9GwCeKJ4Twt2JQJRU4QlMzkYcr1o8
sAoAnjId3mlczi5DhpL1XTANuc1bQ/5P
=mYbg
-----END PGP SIGNATURE-----

--------------enigEC53A75968A6BAF3713BE6EE--
