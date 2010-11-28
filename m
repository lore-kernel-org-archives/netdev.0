From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: Move to staging; remove from defconfig
Date: Sat, 27 Nov 2010 22:38:45 -0800 (PST)
Message-ID: <20101127.223845.189711153.davem@davemloft.net>
References: <20101128002135.GA4562@suse.de>
	<20101127.172644.226781076.davem@davemloft.net>
	<1290909215.3292.230.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-arm-kernel@lists.infradead.org,
	debian-kernel@lists.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750947Ab0K1GiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 01:38:19 -0500
In-Reply-To: <1290909215.3292.230.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 28 Nov 2010 01:53:35 +0000

> On Sat, 2010-11-27 at 17:26 -0800, David Miller wrote:
>> From: Greg KH <gregkh@suse.de>
>> Date: Sat, 27 Nov 2010 16:21:35 -0800
>> 
>> > And I need an ack from the networking maintainer to be able to accept
>> > this also.
>> 
>> I'm not applying this, nor do I want anyone else to.
>> 
>> If people think this protocol is not maintained adequately
>> right now, wait until you push it into staging.
>> 
>> Furthermore, once Phil Blundell was made aware of security
>> holes in econet he fixed them within a few days.  Which is
>> much better than I can say for some of the other protocols
>> and filesystems in the tree.
> 
> Those bugs were present for years and would have been obvious to anyone
> who cared to read the code.  While I very much appreciate Phil's quick
> response, I don't think this reactive maintenance is enough.

These same arguments could for be made for RDS.  Look at all the
hellacious awful obvious crap we've discovered in that code recently.
A simple read would have caught those too, and I don't see it's
maintainer doing such things.

So, you're very much still not convincing Ben, but feel free to keep
trying.
