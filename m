From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 00:41:33 +0200
Message-ID: <200804140041.34843.rjw@sisk.pl>
References: <47FEADCB.7070104@rtr.ca> <20080413205406.GA9190@2ka.mipt.ru> <48028830.6020703@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:37807 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383AbYDMWlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 18:41:19 -0400
In-Reply-To: <48028830.6020703@earthlink.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 14 of April 2008, Stephen Clark wrote:
> Evgeniy Polyakov wrote:
> > On Sun, Apr 13, 2008 at 10:33:49PM +0200, Rafael J. Wysocki (rjw@sisk.pl) wrote:
> >> Things like this are very disappointing and have a very negative impact on bug
> >> reporters.  We should do our best to avoid them.
> > 
> > Shit happens. This is a matter of either bug report or those who were in
> > the copy list. There are different people and different situations, in
> > which they do not reply.
> > 
> Well less shit would happen if developers would take the time to at least test 
> their patches before they were submitted. It like we will just have the poor 
> user do our testing for us. What kind of testing do developers do. I been a 
> linux user and have followed the LKML for a number of years and have yet to see
> any test plans for any submitted patches.

The (apparent) lack of test plans doesn't imply the patches not being tested,
actually.

My experience indicates that they are tested in the majority of cases.  Still,
sometimes they are not and that's when the most damage is done.

Thanks,
Rafael
