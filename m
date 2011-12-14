From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: [WARNING - VERY LONG] A sysadmin's understanding of HFSC and
 IFB
Date: Wed, 14 Dec 2011 00:58:11 -0500
Message-ID: <1323842291.8451.176.camel@denise.theartistscloset.com>
References: <1323415051.3159.25.camel@denise.theartistscloset.com>
	 <1323417599.2529.18.camel@edumazet-laptop>
	 <1323817279.8451.7.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:51683 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978Ab1LNF6P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 00:58:15 -0500
In-Reply-To: <1323817279.8451.7.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-13 at 18:01 -0500, John A. Sullivan III wrote:
> On Fri, 2011-12-09 at 08:59 +0100, Eric Dumazet wrote:
> > Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 02:17 -0500, John A. Sulli=
van III a
> > =C3=A9crit :
> > > Hello, all.  I've been trying to summarize my last week's worth o=
f
> > > research into HFSC and IFB.  Being neither a developer nor a
> > > mathematician, I found most of the existing documentation dauntin=
g and
> > > am truly grateful for the help I received on this list to underst=
and the
> > > technologies.
> > >=20
> > > I do not currently have a blog to post this research and so was t=
hinking
> > > of posting it to this list so that it could be archived and searc=
hable
> > > for other poor sysadmin types like me to save them the days of
> > > struggling to get their practical heads around the concepts.
> > >=20
> > > However, since this is probably a 15 page or so document, I reali=
zed
> > > this could be quite rude to those on dial up or metered connectio=
ns.
> > > Would it be appropriate to post my summary here? Thanks - John
> > >=20
> >=20
> > Please post here, thats definitely a good idea.
> >=20
> > I am pretty sure your contribution could serve to add a page to=20
> >=20
> > http://www.linuxfoundation.org/collaborate/workgroups/networking/gr=
oup
> >=20
> > I believe we lack documentation. A lot.
> <snip>
> OK - it's almost ready.  The only problem I know if is that, when I d=
o
> the math based upon my explanation, I sometimes violate an rt curve w=
hen
> I should not.  I posed that in an email to the list entitled "An erro=
r
> in my HFSC sysadmin documentation".  If anyone can figure out where m=
y
> error is, I will gladly change the documentation.  Here's what I have=
=2E
> The graphics except the ASCII art are obviously missing.  All
> corrections and suggestions very gratefully accepted - John
>=20
<snip>
I realize I was using an incorrect definition of backlogged (needing
more bandwidth than the guaranteed bandwidth) and have corrected (havin=
g
a packet in queue) - John
