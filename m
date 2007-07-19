From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Thu, 19 Jul 2007 08:31:09 -0700
Message-ID: <20070719083109.13b2ab56.rdunlap@xenotime.net>
References: <469E75AA.7040109@pimpmylinux.org>
	<Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
	<20070718134012.cde2f956.randy.dunlap@oracle.com>
	<469E7BE1.6090401@garzik.org>
	<Pine.LNX.4.64.0707181648330.15343@localhost.localdomain>
	<20070718210903.GM3801@stusta.de>
	<Pine.LNX.4.64.0707181712340.16513@localhost.localdomain>
	<20070719054742.GN3801@stusta.de>
	<Pine.LNX.4.64.0707190331330.11902@localhost.localdomain>
	<469F240E.9040205@s5r6.in-berlin.de>
	<Pine.LNX.4.64.0707190523001.19216@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>, Jeff Garzik <jeff@garzik.org>,
	Gabriel C <crazy@pimpmylinux.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:51829 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752889AbXGSP0o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 11:26:44 -0400
Received: from midway.site ([71.117.236.25]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 08:26:41 -0700
In-Reply-To: <Pine.LNX.4.64.0707190523001.19216@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 05:25:30 -0400 (EDT) Robert P. J. Day wrote:

> On Thu, 19 Jul 2007, Stefan Richter wrote:
> 
> > Robert P. J. Day wrote:
> > > On Thu, 19 Jul 2007, Adrian Bunk wrote:
> > >
> > > ...
> > >> I would consider it more ugly to special case this and that in the
> > >> kconfig code when plain dependencies already offer exactly the same
> > >> functionality...
> > >
> > > well, this is the *third* time i've proposed adding this kind of
> > > feature so, at this point, i've really given up caring about it.  if
> > > someone wants to do this, have at it.  i have better things to do than
> > > to keep suggesting it and getting nowhere with it.
> >
> > For better or worse, it can often be observed that feature requests
> > don't set anything in motion until a first patch is sent.  Even a
> > patch that is far from perfect can get things going really quickly.
> > (If the requested feature makes sense to other people.)
> 
> i *did* submit a preliminary patch once upon a time, and it
> (predictably) went nowhere.  so, if someone else wants to pick this up
> and do something with it, you have my blessing.  life's too short to
> keep wasting time on this.

I think that Stefan means a patch to the kconfig source code,
not the the Kconfig files.  Good luck.  I'd still like to see it.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
