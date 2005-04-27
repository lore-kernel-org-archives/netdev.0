From: "Michael Kerrisk" <mtk-lkml@gmx.net>
Subject: Re: is UDP_CORK "real"
Date: Wed, 27 Apr 2005 10:20:28 +0200 (MEST)
Message-ID: <16241.1114590028@www42.gmx.net>
References: <m1u0lty7uh.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Rick Jones <rick.jones2@hp.com> writes:
> > today? While man tcp described TCP_CORK, on the two places I've
> > checked thusfar, man udp does not describe UDP_CORK.  I'm not sure if
> > that means UDP_CORK is "unreal" or just that the udp manpage needs
> > repair (or was out of date on my systems).
>=20
> AFAIK nobody has been updating the protocol manpages since I stopped
> doing so several years ago when they were included into the
> standard manpages.  There are lots of missing features
> etc. that could be documented, the BUGS sections are usually=20
> out of date etc. It is roughly at the state of early 2.3.

I make ocassional changes, as far as my knowledge permits.
But there's lots that I don't know...

> There is also unfortunately no policy to require a manpage
> update when a new feature is added to the kernel.

Yes, unfortunately.

> Some manpages have been even never fully written like the ipv6 manpage.
> Perhaps someone is interested in updating all these? It unfortunately
> needs quite a lot of RTFS to figure out what the code actually does.

I welcome all such patches, which will go into the=20
standard man-pages set (get the latest set at
ftp://ftp.win.tue.nl/pub/linux-local/manpages/ ). =20
Please send patches to: mtk-manpages@gmx.net

In terms of checking people's input, it helps if you identify
how the knowledge going into a patch was obtained, and perhaps
point me at some relevant parts of the source.

Cheers,

Michael

--=20
+++ GMX - die erste Adresse f=FCr Mail, Message, More +++

10 GB Mailbox, 100 FreeSMS  http://www.gmx.net/de/go/topmail
