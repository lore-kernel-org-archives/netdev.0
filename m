From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] virtio_net: Recycle some more rx buffer pages
Date: Sun, 16 Nov 2008 23:14:52 -0800 (PST)
Message-ID: <20081116.231452.177264748.davem@davemloft.net>
References: <20081116.194505.140648013.davem@davemloft.net>
	<20081116.224007.208486442.davem@davemloft.net>
	<200811171738.55143.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, sfr@canb.auug.org.au
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36479
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751048AbYKQHOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:14:52 -0500
In-Reply-To: <200811171738.55143.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 17 Nov 2008 17:38:54 +1030

> On Monday 17 November 2008 17:10:07 David Miller wrote:
> > Even with the mail client corruption fix this thing didn't even apply
> > to net-next-2.6 :-(
> 
> Assume this is the netdev_priv changes.  I'll drop my versions from linux-next 
> to avoid screwing Stephen over.

That's, that was the main point of this :-)
