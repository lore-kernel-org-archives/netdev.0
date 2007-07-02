From: Andres Salomon <dilinger@queued.net>
Subject: Re: [patch] dgrs romove Kconfig option
Date: Mon, 2 Jul 2007 15:32:03 -0400
Message-ID: <20070702153203.f5b10b68.dilinger@queued.net>
References: <20070702135201.GA4779@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Adrian Bunk <bunk@stusta.de>,
	Andres Salomon <dilinger@debian.org>,
	Alan <alan@lxorguk.ukuu.org.uk>
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.queued.net ([207.210.101.209]:1402 "EHLO mail.queued.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752810AbXGBT6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 15:58:16 -0400
In-Reply-To: <20070702135201.GA4779@stro.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Jul 2007 15:52:01 +0200
maximilian attems <max@stro.at> wrote:

> nobody objected to adrian's rfc dropping dgrs on netdev back in dec. 2006.
> -> http://marc.info/?l=linux-netdev&m=116507999803538&w=2
> as bonus points this will get rid of a prorpietary licensed firmware.
> 
> so now be a bit more serious and remove the Kconfig entries
> and see if anyone shouts. if no voice is to be heard as
> expected by zero bug entries on kernel.org or debian.org,
> the full removal is scheduled for 2.6.24.

Why not just do the full removal now?  If someone shouts, it's just as easy
to add it all back.  Leaving around half a driver is just annoying..

-- 
Andres Salomon <dilinger@queued.net>
