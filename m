From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: moving GIT back to kernel.org...
Date: Sat, 08 Oct 2011 00:01:35 -0700
Message-ID: <4E8FF54F.1080306@gmail.com>
References: <20111007.145703.842130763413648388.davem@davemloft.net> <20111007.155902.916470368193047875.davem@davemloft.net> <CAN17JHUGnAbHJmwybjJVdxq4JOgHfDxChw1P7q1yrkqH6Ci05w@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigCCC69D638E5E846D4C83EC23"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, linux-wireless@vger.kernel.org,
	netfilter-devel@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-ide@vger.kernel.org
To: Yinglin Sun <yinglin.s@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAN17JHUGnAbHJmwybjJVdxq4JOgHfDxChw1P7q1yrkqH6Ci05w@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCCC69D638E5E846D4C83EC23
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/07/2011 11:55 PM, Yinglin Sun wrote:
> On Fri, Oct 7, 2011 at 12:59 PM, David Miller <davem@davemloft.net> wro=
te:
>> From: David Miller <davem@davemloft.net>
>> Date: Fri, 07 Oct 2011 14:57:03 -0400 (EDT)
>>
>>> I'm about to setup my GIT trees on kernel.org, once that is complete
>>> I will be solely updating those trees again.
>>>
>>> I will notify everyone when this is ready to go.
>>>
>>> Just a heads up for everyone...
>> Ok, they are now online, please update your URLs.
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc.git
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide.git
>>
> I'm still new to net kernel development, so a little confused about the=
se trees.
> So we should submit patches based on these trees, instead of Linus'?
> About net and net-next, How to decide which one to use?
>
> Thanks!
>
> Yinglin
>

*If* you have change against the network core/drivers then, you would
want to use David Miller's net or net-next trees.

As a general rule:
 - net tree is only for fixes/critical fixes
 - net-next tree is for everything else

There are always exceptions, but if you stick to the above general rule,
you will be fine.


--------------enigCCC69D638E5E846D4C83EC23
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJOj/VPAAoJEOVv75VaS+3OK24P/AudAzx4kltWyzTQHcuBFgOu
TgeM3OQhOSle1Gm+KS26kUrC9zQjtH4gpyoAYLCp4r2cR6OZqbgBvWCE+xkpxuWw
jUKWG5+S1KSTk3kcFwxVFPqgMVosq7dNhZGmFEX49M7SvH5ixfIejYT7u8ZpKyxb
i9rSuH9b/1mATXwc1e5H02HLA4+vKxRcBvKuGnON4YQeXb5mfb1ONtSCpplav53B
Qzns1xL2ylwQh4IHPXKFZa+VJce4DjmUrMgNP7UWAZN9bCrEv9iJ6Pj1itYalDKo
AXx2XSlqOtSj6Mp/bWrMXJlYuijzgE0iYSsoex8WObhIZt0PopocUvdcND6QMBuv
RcSR7mG5uNBN2gVNj8hWFpZkH75nCidqvoeNqdgYZe7rJK+KbB8xKFizblthlHwA
rNVXPft2bAsCUfQOx4EWHZeeYC8VCmThXHsyKbtksrVHFyKpgwQT6RrZupk980gd
/OBYVIOYRdpE1FkxcRKhxpePZmEqz+/KAkgllCKPtVX4ict7958n/550UB5kIbje
chfSTXs4v1MxunN5ItgQ9mr3JW0lcG0ztQo1j9q3u8TVdETKemoLJM9mwyFKyqb7
KP9CCRlrvhb/bdAfk655RT/kvI/A6mreCXk8y1piITUwcjgXO+bvOZC+u087SCqp
5FfliczHfufbUI+DWqOB
=IX+q
-----END PGP SIGNATURE-----

--------------enigCCC69D638E5E846D4C83EC23--
