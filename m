From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 rebased
Date: Fri, 31 Aug 2007 11:58:01 -0700 (PDT)
Message-ID: <20070831.115801.78710940.davem@davemloft.net>
References: <1188475093.2963.13.camel@johannes.berg>
	<20070830.222129.102575067.davem@davemloft.net>
	<20070831134432.GA3352@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, joe@perches.com, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46219
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965968AbXHaS6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 14:58:01 -0400
In-Reply-To: <20070831134432.GA3352@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 31 Aug 2007 09:44:32 -0400

> Sorry, I sent the patch through Jeff.
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-jgarzik/0010-rtl8187-remove-IEEE80211_HW_DATA_NULLFUNC_ACK.patch
> 
> But, it sounds like you have taken care of it...?
> 
> Let me know if I need to fix this.

Thanks for tracking this down, that is exactly the change
I checked into 2.6.24 so everything is good now.
