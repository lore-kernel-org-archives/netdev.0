From: Mario Limonciello <mario_limonciello@dell.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
 Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
 Problem)
Date: Wed, 09 Jul 2008 12:31:59 -0500
Message-ID: <4874F60F.2030501@dell.com>
References: <4861800B.90703@nscus.com>	 <20080625213142.GA29890@electric-eye.fr.zoreil.com>	 <48640535.2050000@nscus.com>	 <20080626215918.GC2555@electric-eye.fr.zoreil.com> <1215435236.11909.121.camel@localhost> <487232F4.6000206@dell.com> <4874EFC5.4070008@nscus.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig98D03D9A84A15847D79F3081"
Cc: Kasper Sandberg <lkml@metanurb.dk>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: mgrollman@nscus.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4874EFC5.4070008@nscus.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig98D03D9A84A15847D79F3081
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Michael:

Sorry, I posted this to the list I received your message from
(netdev@vger.kernel.org).  I don't believe it's been applied by anyone
as of yet.

Regards

Michael Grollman wrote:
> Mario,
>
> Apologies in advance for my ignorance.
>
> When you write below about  'the patch' and 'the list,' can you be a
> bit more specific, particularly about which list you posted it to?
>
> Also, I think Kasper's question below related to, was the patch you
> used to fix your 8169 issues now part of  rc9, or is it still
> independent of the main tree?  For those like me not used to be
> bleeding edge, its cleaner to just snag the rc candidate than to try
> the hand patch method.
>
> Any insight you can offer is appreciated.
>
> Cheers,
>
> - Michael
>
> Mario Limonciello wrote:
>> Kasper:
>>
>> Particularly try the patch that I posted to the list.  It solved the
>> ifup (and resume) failures for me on two platforms using that chipset.=

>>
>> Regards
>>
>> Kasper Sandberg wrote:
>> =20
>>> On Thu, 2008-06-26 at 23:59 +0200, Francois Romieu wrote:
>>>   Sorry for the delay, i had to do an onsite thing in another
>>> country, so
>>> i first see your message now.
>>>
>>> Would it be okay if i took rc9 instead? also, i saw you posted a set =
of
>>> patches to sync more with realteks code, is this something you would
>>> like me to test too, or aswell? (remember, i have the 8111c).
>>>
>>> Btw, a thought just crossed my mind as to a possible reason why this
>>> might be happening, i was googling around, and it seems the TWO nic's=

>>> are supposed to have some sort of hardware bonding thing, could it be=

>>> because such stuff isnt handled?
>>>
>>> mvh.
>>> Kasper Sandberg
>>>
>>> --=20
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>      =20
>>
>>  =20
>

--=20
Mario Limonciello
*Dell | Linux Engineering*
mario_limonciello@dell.com


--------------enig98D03D9A84A15847D79F3081
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFIdPYP2CrZjkA73YsRAhQtAKCfaC0rZDkEvuU5EpNNA0IR7GVKUgCePB3H
eZIumrJlwuNrFKKwg/hhYj0=
=mZDT
-----END PGP SIGNATURE-----

--------------enig98D03D9A84A15847D79F3081--
