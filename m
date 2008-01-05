From: "Manfred Schwarb" <manfred99@gmx.ch>
Subject: Re: driver for et131x?
Date: Sun, 06 Jan 2008 00:35:36 +0100
Message-ID: <20080105233536.170230@gmx.net>
References: <20080104100253.63070@gmx.net>
 <107d3fc0801040302g6350a572if3d0fd5d470b44b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>
To: netdev@vger.kernel.org, "Dean Adams" <dadams1969@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:53862 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753071AbYAEXf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 18:35:59 -0500
In-Reply-To: <107d3fc0801040302g6350a572if3d0fd5d470b44b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> The driver that is available is NOT open souce. It was released under the
> BSD license.
> I tried getting Agere to release under the GPL, but the main dev there
> (Victor) said that it wasn't happening and that we'd have to use it the
> way
> it is.
> 

As far as I know (IANAL), a BSD Licence is open source. In fact, it 
is more liberal than GPL. I think it means you can do whatever you
want, you only have to retain the copyright notice. It is even possible
to fork the code and change the licence to GPL. In fact such things
have already been done in linux. There exists also numerous code in linux
which is dual-licenced under BSD and GPL (which means you can choose one
or the other at your will).

I don't know how the linux community would like to handle things, but
I think it should be possible somehow.

Regards,
Manfred


> On Jan 4, 2008 4:02 AM, Manfred Schwarb <manfred99@gmx.ch> wrote:
> 
> > [ next try, first attempt was blocked because of an '@' in 'X-Sender:'
> > line? ]
> >
> >
> > Hi,
> >
> > meanwhile the Agere et1310 chip has grown to a quite popular network
> > chip, in laptops as well as for PCI-E cards. The release date of this
> chip
> > was
> > already in June 2004, and still no support in mainline linux.
> >
> > There is apparently an opensource driver from Agere which is maintained
> by
> > volunteers at http://sourceforge.net/projects/et131x/
> >
> > It seems some distros (e.g. Ubuntu) even patch their kernels with this
> > driver.
> >
> > Please consider adding support for this chip in mainline linux.
> >
> > Thanks a lot!
> > Manfred
> >
> >
> > see also:
> > http://lkml.org/lkml/2006/7/3/123
> > http://dadams1969.googlepages.com/et131xkernelmodule
> >


-- 
GMX FreeMail: 1 GB Postfach, 5 E-Mail-Adressen, 10 Free SMS.
Alle Infos und kostenlose Anmeldung: http://www.gmx.net/de/go/freemail
