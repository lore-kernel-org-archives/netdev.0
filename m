From: David Miller <davem@davemloft.net>
Subject: Re: phylib: move to dynamic allocation of struct mii_bus
Date: Thu, 09 Oct 2008 09:45:19 -0700 (PDT)
Message-ID: <20081009.094519.103144236.davem@davemloft.net>
References: <20081008.163040.109671916.davem@davemloft.net>
	<20081009093224.GB9038@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754736AbYJIQpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 12:45:43 -0400
In-Reply-To: <20081009093224.GB9038@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 9 Oct 2008 11:32:24 +0200

> On Wed, Oct 08, 2008 at 04:30:40PM -0700, David Miller wrote:
> 
> > Applied to net-next-2.6, thanks!
> 
> This was an older version of the patch (sorry for the confusion),
> please apply this fix patch on top of net-next.
> 
> I've diffed the relevant files in my branch head against net-next
> plus this patch, and that looks as intended.

Applied, thanks for catching this Lennert.
