From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch 1/3 -next] 6LoWPAN: use kfree_skb() instead of kfree()
Date: Thu, 1 Sep 2011 18:04:25 +0300
Message-ID: <20110901150425.GK3705@shale.localdomain>
References: <20110830134552.GH3705@shale.localdomain>
 <1314715248.2935.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAJmB2rBid27YYT4f6vMtBf9EMFWZQgT=xO85z4OBz326pUT+4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:IEEE 802.15.4 SUB..."
	<linux-zigbee-devel@lists.sourceforge.net>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:32889 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932193Ab1IAPGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 11:06:50 -0400
Content-Disposition: inline
In-Reply-To: <CAJmB2rBid27YYT4f6vMtBf9EMFWZQgT=xO85z4OBz326pUT+4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2011 at 01:26:02PM +0400, Alexander Smirnov wrote:
> Hi Dan, Eric,
> 
> thank you a lot for the finds, that were my faults.
> 

So uh...  You're going to send a patch to fix the things Eric
mentioned, right?

regards,
dan carpenter
