From: Quantum Scientific <Info@Quantum-Sci.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 10:29:02 -0600
Message-ID: <200502271029.02532.Info@Quantum-Sci.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <20050228.011038.129063054.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
To: netdev@oss.sgi.com
In-Reply-To: <20050228.011038.129063054.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 27 February 2005 10:10, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=
=8B=B1=E6=98=8E wrote:
> > usagi.snap.split-tool-s20050214.tar.bz2
> > ... however this has no kernel patch within.
> >=20
> > So I DLed=20
> > usagi.snap.kit-linux26-s20050214.tar.bz2
> > ... and no kernel patch here either.  Only the kernel and tools.  I w=
ould=20
have=20
> > to run a USAGI-specific kernel, in order to have proper IPV6 support.=
  I=20
must=20
> > stay with the Debian kernel.
>=20
> I believe you should cry at debian-ipv6 list.
>=20
> And, you can find usagi kernel patch in split directory, and
> you can even find (unsupported) daily kernel snapshot (diff).

I have 'cried' to the Debian list, and no response. (except viruses)

And I have looked at every single file in the Split directory, and there =
are=20
absolutely no .diff files.  .diff files are how patch files are identifie=
d in=20
*nix, of course.  I thought, maybe I should copy the kernel files into my=
=20
kernel tree by hand, for building.  But this doesn't make sense because t=
he=20
only file under usagi-split/kernel/usagi/net/ipv6 is utils.c .  This is n=
ot=20
an IPV6 stack, nor ip6tables.  I see lots of apps, which likely have the=20
USAGI improvements, but no kernel stack, patch, ipv6filters, etc.  And no=
=20
mention of patching a non-USAGI kernel.  Split 20050214 appears to be=20
utilities only.

Please show where could I be going wrong?

Carl Cook
