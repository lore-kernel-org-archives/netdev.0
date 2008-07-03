From: David Miller <davem@davemloft.net>
Subject: Re: v4 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Wed, 02 Jul 2008 21:13:21 -0700 (PDT)
Message-ID: <20080702.211321.118944437.davem@davemloft.net>
References: <486B3B32.3090702@cn.fujitsu.com>
	<486B7AB2.9050104@trash.net>
	<486C46BB.9040206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbYGCENY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 00:13:24 -0400
In-Reply-To: <486C46BB.9040206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 03 Jul 2008 11:25:47 +0800

> v3->v4
> As Patrick said, unregister_netdevice() can do all unwind job
> for ipmr_reg_vif().
> 

Please repost the entire series for me once you've worked
out all of the bugs ;-)
