From: Michael Buesch <mb@bu3sch.de>
Subject: Re: SSB: No is not an answer
Date: Sat, 1 Dec 2007 21:27:49 +0100
Message-ID: <200712012127.50137.mb@bu3sch.de>
References: <20071201171744.GJ30008@ghostprotocols.net> <20071201174532.GA3809@tuxdriver.com> <20071201190023.GK30008@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49227
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbXLAU3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 15:29:46 -0500
In-Reply-To: <20071201190023.GK30008@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 01 December 2007 20:00:23 Arnaldo Carvalho de Melo wrote:
> Em Sat, Dec 01, 2007 at 12:45:32PM -0500, John W. Linville escreveu:
> > On Sat, Dec 01, 2007 at 03:17:44PM -0200, Arnaldo Carvalho de Melo wrote:
> > > Sonics Silicon Backplane support (SSB) [M/y/?] (NEW) n
> > > 
> > > Support for the Sonics Silicon Backplane bus.
> > > You only need to enable this option, if you are
> > > configuring a kernel for an embedded system with
> > > this bus.
> > > It will be auto-selected if needed in other
> > > environments.
> > > 
> > > The module will be called ssb.
> > > 
> > > If unsure, say N.
> > > 
> > > Sonics Silicon Backplane support (SSB) [M/y/?] (NEW)
> > 
> > I think this is OK -- it isn't really offering the choice to say
> > no anyway.  You must have turned-on B44 or B43(LEGACY) already?
> > 
> > So, your choice is merely whether to have it built-in or as a module.
> 
> Ok, so the comment on being unsure is wrong as we can't say N as
> suggested :-)

Oh, come on... Read the _whole_ comment.

-- 
Greetings Michael.
