From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Sat, 5 Jan 2008 21:39:35 +0000
Message-ID: <20080105213935.GN27894@ZenIV.linux.org.uk>
References: <477FF149.4070609@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34167 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756878AbYAEVjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 16:39:36 -0500
Content-Disposition: inline
In-Reply-To: <477FF149.4070609@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2008 at 01:06:17PM -0800, Arjan van de Ven wrote:
> The http://www.kerneloops.org website collects kernel oops and
> warning reports from various mailing lists and bugzillas as well as
> with a client users can install to auto-submit oopses.
> Below is a top 10 list of the oopses collected in the last 7 days.
> (Reports prior to 2.6.23 have been omitted in collecting the top 10)
> 
> This week, a total of 49 oopses and warnings have been reported,
> compared to 53 reports in the previous week.

FWIW, people moaning about the lack of entry-level kernel work would
do well by decoding those to the level of "this place in this function,
called from <here>, with so-and-so variable being <this>" and posting
the results.  As skills go, it's far more useful than "how to trim
the trailing whitespace" and the rest of checkpatch.pl-inspired crap
that got so popular lately...
