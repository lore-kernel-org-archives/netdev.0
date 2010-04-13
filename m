From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] (net-2.6) stmmac update - Apr 2010
Date: Tue, 13 Apr 2010 01:53:52 -0700 (PDT)
Message-ID: <20100413.015352.223941252.davem@davemloft.net>
References: <1270808662-7115-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752355Ab0DMIxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:53:48 -0400
In-Reply-To: <1270808662-7115-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri,  9 Apr 2010 12:24:15 +0200

> Hello,
> this is another subset of patches to make the driver more generic.
> 
> This patches splits the dma and core code for the mac 10/100 device
> (as already done for the gmac) and reorganizes the descriptor
> structures.
> In the first version of the driver, the mac10/100 could only use
> normal descriptors and the gmac could only use the enhanced ones.
> This limit has been removed and this kind of information comes
> from the platform.

Please:

1) respin your patches against net-next-2.6

2) Add numbers to your patch posting subject lines so there
   is no confusion about what order your patches should be
   applied.

3) Make sure the driver compiles successfully at each step
   of applying your patches, not just after all the changes
   are applied.


Thanks.
