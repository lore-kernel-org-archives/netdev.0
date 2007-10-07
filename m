From: Andreas Mohr <andi@lisas.de>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by
	ISDN
Date: Sun, 7 Oct 2007 15:17:24 +0200
Message-ID: <20071007131723.GA22873@rhlx01.hs-esslingen.de>
References: <20071007120653.GA16184@rhlx01.hs-esslingen.de> <4708D00D.8030307@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Mohr <andi@lisas.de>, isdn4linux@listserv.isdn4linux.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:43090 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbXJGNRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 09:17:25 -0400
Content-Disposition: inline
In-Reply-To: <4708D00D.8030307@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 07, 2007 at 08:24:45AM -0400, Jeff Garzik wrote:
> It definitely looks like ISDN is somehow to blame.  Any chance you could 
> try git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.24.git ?

I'm afraid I won't make it, since this server is not at my home
location, is a ""production"" server and takes only exactly 200 minutes
for a kernel build (K6-3/150).

I thus decided to now try plain 2.6.23-rc8 whether it's "corrupted", too.

> That would help narrow down the problem to a very-large set of 
> networking changes pending for 2.6.24.

...only if I have a known-working very recent version, which is exactly
the problem now.

Andreas Mohr
