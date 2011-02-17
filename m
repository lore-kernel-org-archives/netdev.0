From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [PATCH net-2.6/stable] tg3: Restrict phy ioctl access
Date: Wed, 16 Feb 2011 16:56:06 -0800 (PST)
Message-ID: <20110216.165606.193703255.davem@davemloft.net>
References: <20110216235248.GA11108@mcarlson.broadcom.com>
	<20110216.161025.59672084.davem@davemloft.net>
	<20110217003947.GA11185@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, netdev@vger.kernel.org, stable@kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752008Ab1BQAza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 19:55:30 -0500
In-Reply-To: <20110217003947.GA11185@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 16 Feb 2011 16:39:47 -0800

> So the proper thing to do here is recall the patch, submit a new patch
> to net-2.6 with a CC: stabel@kernel.org in the signed-off-by section.

No.

I have not applied your patch yet, but when I do and I also get my
tree pulled next time into Linus's tree, you can ask stable to apply
it.

Because only at that point will it exist as a commit in Linus's tree.

Before that happens you cannot ask Greg to apply it to his tree.
