From: Jeroen Massar <jeroen@unfix.org>
Subject: Re: (usagi-users 03234) Re: support of IPv6 by NFS
Date: Wed, 02 Mar 2005 16:29:41 +0100
Message-ID: <1109777381.17484.206.camel@firenze.zurich.ibm.com>
References: <200503020721.j227Ldir012381@m5p.com>
	 <200503020713.33133.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-U3/aXNwvcqoFErbsrLHf"
Cc: netdev@oss.sgi.com
To: usagi-users@linux-ipv6.org
In-Reply-To: <200503020713.33133.Info@Quantum-Sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-U3/aXNwvcqoFErbsrLHf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2005-03-02 at 07:13 -0600, Quantum Scientific wrote:
>On Wednesday 02 March 2005 1:21, Elliott Mitchell wrote:
>> >From: Quantum Scientific <Info@quantum-sci.com>
>> > On Tuesday 01 March 2005 19:19, Elliott Mitchell wrote:
<SNIP>
>You're not listening.  You must be a Republican.

Very technical.

>Of course, there's the guy who's asking how to subvert packets before they=
 get=20
>to ip6tables processing...  anybody else wonder why he wants that?  Notice=
=20
>there's no real answer?  He really knows what he's doing, and can't get=20
>through ip6tables.  This will be instructive to most.

Which guy is asking this? Everybody, at least when you are a bit into
kernel programming, that you can do this at a couple of levels and all
of these are inside the kernel (driver, network layers) + hardware and
of course the cable itself.

>=20
>> Patching is of much greater importance than even the best of firewalls.
>...
>> A system without a firewall, but secure software is safe. A system with
>> a firewall, but insecure software is unsafe.
>
>Although updating is important, the above are nutty ideas.  Your membershi=
p in=20
>the Flat Earth Society(tm) is confirmed.  Your salary will henceforth be p=
aid=20
>in Confederate dollars, your medical insurance revoked (it's socialist), a=
nd=20
>your retirement invested in the stock market.  Remember: "War is peace. =20
>Freedom is slavery.  Ignorance is strength."
> {goes to rent Fahrenheit 451 and The Handmaiden's Tale}

Whee, free money! :)
>
>> There could be a buffer overflow in the device driver. There could be an
>> overflow in code between the driver netfilter code. These two places are
>> unlikely as they're constructed carefully, but it could happen. You coul=
d
>> also have a hole in how your system log handling software which could be
>> triggered through the above firewall. Been a while since the last one,
>> but such holes have been found before, and that are doesn't tend to get
>> as much scrutiny as the kernel.
>
>In order for a buffer overflow to be of use to an attacker, he must be abl=
e to=20
>instigate it, and inject his own code...  when was the last time you've he=
ard=20
>of a NIC driver sploit?  Who's going to work for weeks on this, when there=
=20
>are thousands of machines like yours out there, only filtering SYN.

What is bad with filtering SYN?

>These=20
>are not risks for a properly firewalled machine.

Ever run a PIX or FW1? Ask them how nice it was that when they learned
about the magic of fragments and the nice ways you can circument them.
Good that we don't have IP fragments anymore now. Still keeps TCP
fragments though.

Ever heard about tunneling over DNS and many other ways of circumventing
firewalls? Ever read Full-Disclosure, ever been to a security
conference, read a good security paper? I'd suggest you do so.
Computers are not like houses, then again, maybe you can compare a
firewall to a lock that you can open with a crowbar ;)

>  I'm getting the idea you=20
>have this opinion because you had constructed a poor firewall and been=20
>compromised.  This is why I wish Shorewall would take up the mantle.

I don't even use firewalling, except for dropping sources that should
not exist in the first place.

Then again my apps nicely behave on the correct ports and interfaces :)

>Elliott, I've been hoping you are sincere in this discussion, but it now=20
>appears you are just trolling.  I've had enough of you.
>
>Carl Cook

Very nice to call someone a troll when you are named "Cook" :)
Really, personal attacks don't help your non-technical arguments and
trying to insult people. Btw, where are the 'back-comments' about me?

Everybody knows that IPv6 is still in development, accept that, it will
come, but it is not here today. Puncto.

Greets,
 Jeroen


--=-U3/aXNwvcqoFErbsrLHf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Jeroen Massar / http://unfix.org/~jeroen/

iD8DBQBCJdvlKaooUjM+fCMRAntNAKCQtxcX+QIrJzSmh+VyjEWHXZsZowCfXHfd
8UdLeAFNrrRal+Lt7CbUGng=
=Efpb
-----END PGP SIGNATURE-----

--=-U3/aXNwvcqoFErbsrLHf--
