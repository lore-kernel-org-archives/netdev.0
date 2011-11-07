From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Contributing for the first time
Date: Mon, 7 Nov 2011 08:11:20 -0800
Message-ID: <20111107081120.754f6e0a@nehalam.linuxnetplumber.net>
References: <CAPhGq=b_DwhbChAm3HPfzTXedRM6qVvVW7an5YkM8hqwhgCjbA@mail.gmail.com>
	<4a08f8c6-d02e-40c4-b976-5437270ba5b2@email.android.com>
	<CAEnQRZA=dwt6TjcBacYaj0ORdi5QjBEXUaPA4GT2tm2oE_LFew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexandru Juncu <alex.juncu@rosedu.org>,
	kernelnewbies@kernelnewbies.org,
	Greg Freemyer <greg.freemyer@gmail.com>, netdev@vger.kernel.org
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [76.74.103.46] ([76.74.103.46]:60156 "EHLO mail.vyatta.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751342Ab1KGQMi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 11:12:38 -0500
In-Reply-To: <CAEnQRZA=dwt6TjcBacYaj0ORdi5QjBEXUaPA4GT2tm2oE_LFew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Nov 2011 15:17:38 +0200
Daniel Baluta <dbaluta@ixiacom.com> wrote:

> On Mon, Nov 7, 2011 at 3:05 PM, Greg Freemyer <greg.freemyer@gmail.co=
m> wrote:
> > Alexandru Juncu <alex.juncu@rosedu.org> wrote:
> >
> >>Hello!
> >>
> >>I have been a linux user for many years, and mostly on the networki=
ng
> >>side. And I would like to start contributing somehow to the linux
> >>community (in some other way than just promoting it). I guess that =
=A0I
> >>should start small with something like man pages.
> >>
> >>And there is something that really has been bugging me for some tim=
e.
> >>I'm an iproute2 user and I teach linux courses and show people how =
to
> >>use it. On most questions from my students about new commands, I
> >>redirect them to the man pages and to the Examples section of that
> >>page. iproute2 doesn't have such examples and I always wish it did.
> >>
> >>Do you think that if I submit a patch to the man pages, adding some
> >>examples of how to use the ip command, will it get accepted? Becaus=
e
> >>this sounds like a simple thing and it's hard to believe that someo=
ne
> >>else didn't try do to this before. What do you think?
> >>Alexandru Juncu
>=20
> > I think it will be accepted, but few people like to work on the man=
 pages.
> >
> > Since this is a userspace package you will need to figure out who t=
he maintainer is and if there is a mailinglist they use to discuss/supp=
ort the package.
> >
> > Then submit your patch there.
>=20
> According to [1] maintainer for iproute2 is Stephen Hemminger (CC'ed)=
 and I
> think patches should be sent to netdev mailing list ([2]).
>=20
> thanks,
> Daniel.
>=20
> [1] http://www.linuxfoundation.org/collaborate/workgroups/networking/=
iproute2
> [2] http://vger.kernel.org/vger-lists.html#netdev

It might also be worth it to break some of the large manual pages into
clearer sections.
