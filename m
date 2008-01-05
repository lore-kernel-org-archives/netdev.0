From: Christoph Hellwig <hch@infradead.org>
Subject: Re: driver for et131x?
Date: Sat, 5 Jan 2008 08:58:24 +0000
Message-ID: <20080105085823.GA19656@infradead.org>
References: <20080104100253.63070@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dean Adams <dadams1969@gmail.com>
To: Manfred Schwarb <manfred99@gmx.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34882 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbYAEI6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 03:58:25 -0500
Content-Disposition: inline
In-Reply-To: <20080104100253.63070@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 04, 2008 at 11:02:53AM +0100, Manfred Schwarb wrote:
> meanwhile the Agere et1310 chip has grown to a quite popular network
> chip, in laptops as well as for PCI-E cards. The release date of this chip was
> already in June 2004, and still no support in mainline linux.
> 
> There is apparently an opensource driver from Agere which is maintained by
> volunteers at http://sourceforge.net/projects/et131x/
> 
> It seems some distros (e.g. Ubuntu) even patch their kernels with this driver.
> 
> Please consider adding support for this chip in mainline linux.

The driver on the above site would need quite a bit of work to bring it
up to Linux standards.  That work shouldn't be difficult but enough to
keep someone busy for a while.  If you have the hardware I'd be happy yo
guide you through the required work.  Are you interested in taking up
this project?

