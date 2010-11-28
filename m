From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: Move to staging; remove from defconfig
Date: Sat, 27 Nov 2010 17:26:44 -0800 (PST)
Message-ID: <20101127.172644.226781076.davem@davemloft.net>
References: <1290897868.3292.59.camel@localhost>
	<20101128002135.GA4562@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-arm-kernel@lists.infradead.org,
	debian-kernel@lists.debian.org
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40331
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750817Ab0K1B0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 20:26:19 -0500
In-Reply-To: <20101128002135.GA4562@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@suse.de>
Date: Sat, 27 Nov 2010 16:21:35 -0800

> And I need an ack from the networking maintainer to be able to accept
> this also.

I'm not applying this, nor do I want anyone else to.

If people think this protocol is not maintained adequately
right now, wait until you push it into staging.

Furthermore, once Phil Blundell was made aware of security
holes in econet he fixed them within a few days.  Which is
much better than I can say for some of the other protocols
and filesystems in the tree.

Moving this into staging, is therefore not appropriate.
