From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Wed, 17 May 2017 20:07:00 -0400
Message-ID: <4a873ea1-ba83-1506-9172-e955d5f9ae16@redhat.com>
References: <1494955244.3259.130.camel@redhat.com>
 <20170516.133644.850927380166261577.davem@davemloft.net>
 <1494957802.3259.131.camel@redhat.com>
 <20170516.145249.871010194359061722.davem@davemloft.net>
 <1494962899.3259.141.camel@redhat.com> <1495053467.2240.29.camel@redhat.com>
 <VI1PR0502MB3008604A216B388A440A8B53D1E70@VI1PR0502MB3008.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="l1PagFi8x94784DWExn9P1tiMwUsRV8Qh"
Cc: "Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org" <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <VI1PR0502MB3008604A216B388A440A8B53D1E70-o1MPJYiShExKsLr+rGaxW8DSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--l1PagFi8x94784DWExn9P1tiMwUsRV8Qh
Content-Type: multipart/mixed; boundary="8J00RGaq8GTehC5Fx329qPCnS0VB1lAHB";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: "Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org" <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
 "torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
 "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
 <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Message-ID: <4a873ea1-ba83-1506-9172-e955d5f9ae16-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
References: <1494955244.3259.130.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20170516.133644.850927380166261577.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
 <1494957802.3259.131.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20170516.145249.871010194359061722.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
 <1494962899.3259.141.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> <1495053467.2240.29.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <VI1PR0502MB3008604A216B388A440A8B53D1E70-o1MPJYiShExKsLr+rGaxW8DSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
In-Reply-To: <VI1PR0502MB3008604A216B388A440A8B53D1E70-o1MPJYiShExKsLr+rGaxW8DSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>

--8J00RGaq8GTehC5Fx329qPCnS0VB1lAHB
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 5/17/2017 6:37 PM, Parav Pandit wrote:
> Hi Doug,
>=20

>> It would have been better with AF_INET/AF_INET6 and an option to enabl=
e
>> SMC than AF_SMC.  The first implementation simply assumes AF_INET in
>> the presence of AF_SMC.  When IPv6 support is added, some sort of
>> guessing logic will have to be put in place to try and determine if an=

>> AF_SMC address is actually AF_INET or AF_INET6 since we won't have a
>> guaranteed way of telling.  Apps can use struct sockaddr_storage as th=
eir
>> normal element to stick the address into, and could rely on the kernel=
 to
>> interpret it properly based on the AF_INET/AF_INET6 differentiation, a=
nd
>> this breaks that.  The RFC gives *some* thought to adding IPv6 in the
>> future, but not a lot.  It may be that the answer is that in the futur=
e, IPv6
>> support is enabled by making the IPv6 API be
>> AF_INET6 + setsockopt(SMC) or the equivalent.  If that's the case, the=
n I
>> would suggest making the later API specifically call out AF_INET +
>> setsockopt(SMC) be identical to AF_SMC.
>>
>=20
> What are the shortcomings in my proposal [1] which I am reiterating bel=
ow.
> Bart also suggested to define new stream protocol for SMC similar to SC=
TP.
>=20
> (a) address family should be either AF_INET or AF_INET6
> (b) socket() API to introduce new protocol as PROTO_SMC for in socket()=
 system call.
>=20
> With this there is no additional setsockop() needed.
>=20
> With this - user space applications, do getaddrinfo() with hint as
> hints.ai_family  =3D AF_INET;
> hints.ai_socktype =3D SOCK_STREAM;
>=20
> getaddrinfo() returns back both the protocols TCP and SMC.
> Famous database application such as Redis client iterates over all entr=
ies of getaddrinfo() and establishes connection to servers.
>=20
> There are few advantages of this interface.
> 1. No change in any makefile of applications needed - unless user wants=
 to specify explicitly that it wants to force SMC protocol.
> 2. No need to do LD_LIBRARY_PRELOAD, (which won't work anyway because b=
ind() connect() of SMC checks for AF_INET).
> 3. No major changes to glibc to process AF_SMC differently
> glibc references IPPROTO_TCP at 22 places. (compare to AF_INET at 140+ =
places).
> A lot simpler test matrix for glibc for new protocol
> 5. No need to recompile applications, as long as getaddrinfo returns al=
l streaming protocols (TCP, SMC)
> 6. for applications to make use of setsockopt() it needs another knob a=
nd hint from other places, which can be avoided because SMC TCP option ne=
gotiates with remote end
>=20
> And representing new protocol as new protocol for a given address famil=
y appears correct, compare to setting socket options.
>=20
> Tools like CRIU or similar tool might find a race conditions - when it =
queries socket option, SMC was not set, but later on SMC was set, and doe=
s incorrect handling.
> Setting socket() with SMC protocol makes it easier to understand in thi=
s area as well.

I have no problem with the proposal in itself, but as IBM released this
publication and did their own implementation prior to submitting things
upstream, and as there might exist in the field implementations, it
depends on whether we wish to call those in the field implementations
experimental and break them as we go to a final implementation of
version 1, or if we consider version 1 baked.  I'm fine breaking it.
After all, that's what happened with XRC back in the day and Mellanox
learned a valuable lesson about upstream first.  I have no problem with
IBM learning that same lesson IMO.  So, I find your proposal, including
breaking the API of the version 1 implementation just taken into the
kernel before it has had time to fully sit and gel, acceptable.

But this is where we kind of need a judgment from on high, and why I
Cc:ed Linus on this thread.  Any input on this issue Linus?

> I have additional proposal for link groups, resource creation area. I w=
ill take that up after this discussion.

Look forward to hearing it.

> [1] https://patchwork.kernel.org/patch/9719375/


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FD=
D


--8J00RGaq8GTehC5Fx329qPCnS0VB1lAHB--

--l1PagFi8x94784DWExn9P1tiMwUsRV8Qh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJZHOWkAAoJELgmozMOVy/djkAQALAdnF2d7RfLw9mFQigXxi8i
zakv+IvVSL5tQGp54Zfo5ecJXNo6ApJpfy0dozmAURJzLylEes4gYajilHw67yzA
R0x6QvsAf5/+1XOGWHCgQ11J1L1wINwFp6Msnd437zWB+k1YRowmDBUp2iEcwvQw
PNdITzHxEBP2FqJKKlBqm6nemVC+LP9/bUx2cOnKWs/MV1ceevP1nGQBflLzkzUZ
tNf7LzIPZpr+tzEwy2xpMwHZm8UZMBH53VHqE5Z3OB5+Kkf+q71MuhCdOPcS95w4
PkLnMmUxCcYPj3l6f8neVnW5SE55QuCJ7zHQTGY4U5EIhdBLzXigwj7Ihgg4bHyI
NsHmmbJUg0cR78GyEaJT3u3luHQtN0TXSkhfEMdrpQ2wFGYWwrRe2kELc7BhQwQE
SA6hXAm0PP+B9w1mfn6/wGSHuAdax0jW9uWWpAmt3DMfJDjAdlVhcgIP66qU6EJU
o5pqaxlK6Hc0oMfHP1dUI9wcntdOI55aRj5NFHF6wdjqMdNphHPHA0lBv+iCKwWv
PLSG8iqm8+cqjWbunExIyByc7/u5A7MVxnCoTKiYtIVg6GUMeU8NsXnxIptPucol
ZPJ/7YQDO8TsJWXujA++y6OliLjx+8GVch3P+lDMjUNZY2YunubFTlIM3IKScmka
fgpetAwjPupAwk54tB6M
=kCfs
-----END PGP SIGNATURE-----

--l1PagFi8x94784DWExn9P1tiMwUsRV8Qh--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
