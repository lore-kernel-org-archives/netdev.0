From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Wed, 21 Nov 2012 17:40:14 -0500 (EST)
Message-ID: <20121121.174014.268181096393133050.davem@davemloft.net>
References: <1353529639.26346.164.camel@shinybook.infradead.org>
	<20121121204045.GA17627@electric-eye.fr.zoreil.com>
	<1353537131.26346.199.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, jgarzik@pobox.com, jasowang@redhat.com,
	netdev@vger.kernel.org, hayeswang@realtek.com, gilboad@gmail.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965054Ab2KVTPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 14:15:31 -0500
In-Reply-To: <1353537131.26346.199.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 21 Nov 2012 22:32:11 +0000

> On Wed, 2012-11-21 at 21:40 +0100, Francois Romieu wrote:
>> Straight to -stable ?
> 
> That's the way it works. You put the Cc: stable on the *original* commit
> that goes upstream. There's no sane way to retroactively add that tag
> after it's already been merged and tested.
> 
> Yes, you can bug Greg manually to 'please add this upstream commit which
> we forgot to mark as Cc: stable' but that isn't the way it's usually
> done.

On the contrary, for networking I submit everything manually and I
remove the CC: tags.

I have a queue on patchwork that I add such patches to, so that they
do not get lost.
