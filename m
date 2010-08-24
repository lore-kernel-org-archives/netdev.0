From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bna: fix stats handling
Date: Tue, 24 Aug 2010 12:36:45 -0700 (PDT)
Message-ID: <20100824.123645.39174077.davem@davemloft.net>
References: <20100823.203552.63040549.davem@davemloft.net>
	<1282627901.2378.1451.camel@edumazet-laptop>
	<E5313AF6F2BFD14293E5FD0F94750F86A4AE225D69@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	amathur@brocade.com, ddutt@Brocade.COM, huangj@Brocade.COM
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753317Ab0HXTg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 15:36:27 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A4AE225D69@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 24 Aug 2010 11:49:45 -0700

> We tried applying the patch to the source, it looks corrupted. Can
> you please resubmit the patch?

His patch applies absolutely cleanly to net-next-2.6

I had to make fixes to your driver, as I mentioned when I checked
in your patch yesterday, so you absolutely must test against
what I added to net-next-2.6 and not what you have locally in
your trees.
