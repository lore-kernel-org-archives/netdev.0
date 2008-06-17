From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bridge: use statistics in net_device
Date: Tue, 17 Jun 2008 16:50:25 -0700 (PDT)
Message-ID: <20080617.165025.36340275.davem@davemloft.net>
References: <20080617165223.258482526@vyatta.com>
	<20080617.161409.132612527.davem@davemloft.net>
	<20080617163527.40c9ecd3@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57326
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759544AbYFQXuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:50:25 -0400
In-Reply-To: <20080617163527.40c9ecd3@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 17 Jun 2008 16:35:27 -0700

> On Tue, 17 Jun 2008 16:14:09 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Tue, 17 Jun 2008 09:52:14 -0700
> > 
> > > Move statistics to net_device structure. Also, update last_rx on bridge
> > > device (even though only bonding seems to use it).
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > This patch doesn't apply even remotely to anything I have in my tree.
> > What did you generate this against?
> 
> 
> Patch was against 2.6.26-rc6

Yet claimed for "2.6.27" :-)

