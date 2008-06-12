From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates for .27
Date: Thu, 12 Jun 2008 15:22:14 -0700 (PDT)
Message-ID: <20080612.152214.21877307.davem@davemloft.net>
References: <20080612133842.0dc472bc.sfr@canb.auug.org.au>
	<20080611.212929.71729484.davem@davemloft.net>
	<48519E57.3030906@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46210
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754527AbYFLWWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 18:22:13 -0400
In-Reply-To: <48519E57.3030906@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 12 Jun 2008 18:08:23 -0400

> Did you actually read the commit description?  It's quite clear who 
> originated the commit:
> 
> 
> commit 0c1aa20fb87b796d904f4d89ad12e5a0c483127b
> Author: Stephen Rothwell <sfr@canb.auug.org.au>
> Date:   Thu May 29 22:39:28 2008 +1000
> 
>      [netdrvr] Fix 8390 build breakage
> 
>      From: tony@bakeyournoodle.com (Tony Breeds)

To each their own, I suppose, but...

If you look at what happens when Andrew dumps a thousand patches to
Linus this isn't how it is handled.

"Author" is always who wrote the patch, and I think it's important to
be consistent in that area.

Stephen Rothwell isn't the "Author" of this patch any more than you
are Jeff.  By your own logic, you are saying that you could have just
as equally put yourself in the Author field since hey, you're
effectively submitting the patch to me via your tree right? :-)

