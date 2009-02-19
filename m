From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] e1000: Removing the unused macro
 PAGE_USE_COUNT()
Date: Thu, 19 Feb 2009 14:39:02 -0800 (PST)
Message-ID: <20090219.143902.191292595.davem@davemloft.net>
References: <499AD0D4.2000504@linux.vnet.ibm.com>
	<9929d2390902171527q62af2fdcnb99a9dd45e2b13bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbZBTCRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 21:17:52 -0500
In-Reply-To: <9929d2390902171527q62af2fdcnb99a9dd45e2b13bb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 17 Feb 2009 15:27:01 -0800

> On Tue, Feb 17, 2009 at 6:59 AM, Breno Leitao <leitao@linux.vnet.ibm.com> wrote:
> > Removing the unused macro PAGE_USE_COUNT(), since there is no more reference
> > to it. The last reference was removed by Jesse's commit number
> > 630b25cdf4e3f8c0a11eb04fc8436cc36653cd58.
> >
> > Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> > ---
> >  drivers/net/e1000/e1000_main.c |    2 --
> >  1 files changed, 0 insertions(+), 2 deletions(-)
> >
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks everyone.
