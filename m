From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: b43 is broken in latest net-2.6 and linux-2.6
Date: Mon, 28 Sep 2009 14:42:11 -0400
Message-ID: <20090928184211.GC4737@tuxdriver.com>
References: <4AB4BF1F.7070501@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43370 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845AbZI1SqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 14:46:07 -0400
Content-Disposition: inline
In-Reply-To: <4AB4BF1F.7070501@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 19, 2009 at 01:23:11PM +0200, Oliver Hartkopp wrote:
> Hello Michael,
> 
> my b43 wireless card (Dell 830) is not working with the latest net-2.6 (and
> also linux-2.6 2.6.31-05767-gdf58bee).
> 
> net-2.6 2.6.31-03263-gc29854e is working
> net-2.6 2.6.31-03301-ga97e178 is broken
> 
> I removed the patch with the work_queue stuff which did not help - so it's
> probably the other patch you added to b43 recently.
> 
> Don't know ... the wlan0 link does not become ready anymore.
> 
> If you need some more information - please let me know.

Is this working better now, with 2.6.31-rc1?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
