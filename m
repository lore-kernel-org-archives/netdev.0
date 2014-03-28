From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] mac802154: stop tx queue before destroy
 workqueue
Date: Fri, 28 Mar 2014 17:06:53 -0400 (EDT)
Message-ID: <20140328.170653.1370606349680379319.davem@davemloft.net>
References: <1395944600-18330-1-git-send-email-alex.aring@gmail.com>
	<20140328132026.GA29114@omega.Speedport_W_921V_1_24_000>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaC1VG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:06:56 -0400
In-Reply-To: <20140328132026.GA29114@omega.Speedport_W_921V_1_24_000>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Fri, 28 Mar 2014 14:20:29 +0100

> please drop this patch... I having still some issues to unloading the
> at86rf230 driver while transmitting... I don't giving up to fix that issue...
> 
> Sorry, I need some time to understand what's going on there.

Ok.
