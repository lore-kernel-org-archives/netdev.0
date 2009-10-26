From: Greg KH <greg@kroah.com>
Subject: Re: wanPMC-CxT1E1
Date: Mon, 26 Oct 2009 14:20:24 -0700
Message-ID: <20091026212024.GA11918@kroah.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
 <20091026204144.GA28436@kroah.com>
 <4f6ba3b0910261357x2e5bdf5byb03b1debd177ec86@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Bob Beers <bob.beers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:56249 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751AbZJZVXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 17:23:33 -0400
Content-Disposition: inline
In-Reply-To: <4f6ba3b0910261357x2e5bdf5byb03b1debd177ec86@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2009 at 04:57:35PM -0400, Bob Beers wrote:
> On Mon, Oct 26, 2009 at 4:41 PM, Greg KH <greg@kroah.com> wrote:
> > On Mon, Oct 26, 2009 at 04:22:08PM -0400, Bob Beers wrote:
> >> Hello List,
> >>
> >> I am using subject named card[1] and it has a GPL driver that is
> >> =A0out-of-tree. =A0I have permission from the manufacturer to post=
 and
> >> =A0discuss it, so I'd like to get started. =A0Where/how shall I po=
st the code,
> >> =A0and my first patch which allows it to compile and run with the
> >> =A0kernel of RHEL/CentOS 5? =A0The tarball includes driver source =
and
> >> =A0a utility pmcc4cfg, and is 174 093 bytes.
> >
> > Getting it to build on 2.6.31 is more important than RHEL5, we can'=
t do
> > anything with an old kernel like that.
> >
>=20
> I know, but I'll need to back port it as soon as possible.

Sure, but that's nothing we can do, nor are able to even care about :)

> > Do you have a pointer to where we can download the tarball? =A0I'll=
 be
> > glad to add it to the staging tree so it can be cleaned up there be=
fore
> > being submitted to the main portion of the kernel tree.
> >
>=20
> <http://rapidshare.com/files/298314343/wanPMC_CxT1E1_Linux_3_1B.tgz.h=
tml>
> MD5: 563FC98A1A0EA625F72C45B89E5C726B

Care to put it somewhere that will actually work?  That site refuses to
give it to me.

Heck, if it's only 174kb, can you just send it in email to me?

thanks,

greg k-h
