From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: SSB: No is not an answer
Date: Sun, 2 Dec 2007 10:19:35 -0200
Message-ID: <20071202121935.GL30008@ghostprotocols.net>
References: <20071201171744.GJ30008@ghostprotocols.net> <20071201174532.GA3809@tuxdriver.com> <20071201190023.GK30008@ghostprotocols.net> <200712012127.50137.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754527AbXLBMUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 07:20:37 -0500
Content-Disposition: inline
In-Reply-To: <200712012127.50137.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Dec 01, 2007 at 09:27:49PM +0100, Michael Buesch escreveu:
> On Saturday 01 December 2007 20:00:23 Arnaldo Carvalho de Melo wrote:
> > Em Sat, Dec 01, 2007 at 12:45:32PM -0500, John W. Linville escreveu:
> > > On Sat, Dec 01, 2007 at 03:17:44PM -0200, Arnaldo Carvalho de Melo wrote:
> > > > Sonics Silicon Backplane support (SSB) [M/y/?] (NEW) n
> > > > 
> > > > Support for the Sonics Silicon Backplane bus.
> > > > You only need to enable this option, if you are
> > > > configuring a kernel for an embedded system with
> > > > this bus.
> > > > It will be auto-selected if needed in other
> > > > environments.
> > > > 
> > > > The module will be called ssb.
> > > > 
> > > > If unsure, say N.
> > > > 
> > > > Sonics Silicon Backplane support (SSB) [M/y/?] (NEW)
> > > 
> > > I think this is OK -- it isn't really offering the choice to say
> > > no anyway.  You must have turned-on B44 or B43(LEGACY) already?
> > > 
> > > So, your choice is merely whether to have it built-in or as a module.
> > 
> > Ok, so the comment on being unsure is wrong as we can't say N as
> > suggested :-)
> 
> Oh, come on... Read the _whole_ comment.

Oh well, if you think that it is OK, so be it, I found it confusing and
reported, you find it ok to suggest chosing 'N' when 'M' or 'y' are the
only possible answers. 

Perhaps telling that N is not a possible answer when B44 or B43 was
previously selected could help, up to you.

- Arnaldo
