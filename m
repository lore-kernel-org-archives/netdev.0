From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: SSB: No is not an answer
Date: Sat, 1 Dec 2007 12:45:32 -0500
Message-ID: <20071201174532.GA3809@tuxdriver.com>
References: <20071201171744.GJ30008@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4190 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248AbXLARqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 12:46:20 -0500
Content-Disposition: inline
In-Reply-To: <20071201171744.GJ30008@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 01, 2007 at 03:17:44PM -0200, Arnaldo Carvalho de Melo wrote:
> Sonics Silicon Backplane support (SSB) [M/y/?] (NEW) n
> 
> Support for the Sonics Silicon Backplane bus.
> You only need to enable this option, if you are
> configuring a kernel for an embedded system with
> this bus.
> It will be auto-selected if needed in other
> environments.
> 
> The module will be called ssb.
> 
> If unsure, say N.
> 
> Sonics Silicon Backplane support (SSB) [M/y/?] (NEW)

I think this is OK -- it isn't really offering the choice to say
no anyway.  You must have turned-on B44 or B43(LEGACY) already?

So, your choice is merely whether to have it built-in or as a module.

John
-- 
John W. Linville
linville@tuxdriver.com
