From: Michal Vanco <vanco@satro.sk>
Subject: Re: e1000 packet corruption problem
Date: Wed, 30 Mar 2005 09:04:28 +0200
Message-ID: <424A4F7C.2070104@satro.sk>
References: <C925F8B43D79CC49ACD0601FB68FF50C03793405@orsmsx408>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAA4AC246E32393D810058A69"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C03793405@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAA4AC246E32393D810058A69
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Brandeburg, Jesse wrote:
> You might be having interrupt routing problems, have you tried
> pci=noapic as a boot parameter?
>
hi

pci=noapic doesn't work (PCI: Unknown option `noapic' in dmesg).

tried also noapic and pci=noacpi params with the same result (packet
corruption).

regards,
michal

--------------enigAA4AC246E32393D810058A69
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFCSk9+SBxxqpMaGkMRAqczAJ46EWCqWLF3NgZjljV6bfm1xB+ZOgCfafuj
2YrYHu5D1zs7P4hmw0KIWhw=
=2nm6
-----END PGP SIGNATURE-----

--------------enigAA4AC246E32393D810058A69--
