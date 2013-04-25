From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: mac802154: comparision issue of type cast,
 finding by EXTRA_CFLAGS=-W
Date: Thu, 25 Apr 2013 05:01:10 -0400 (EDT)
Message-ID: <20130425.050110.1637872699710810114.davem@davemloft.net>
References: <51766F74.2090007@asianux.com>
	<20130425.041044.768895561908042668.davem@davemloft.net>
	<5178ECA2.6020402@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab3DYJBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 05:01:12 -0400
In-Reply-To: <5178ECA2.6020402@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Thu, 25 Apr 2013 16:43:14 +0800

> (the change is for net/mac802154/mac802154.h, and exist in v3.9-rc8)

It exist, but your patch doesn't apply cleanly there, it only applies
cleanly to the -next tree, because other changes have happend to that
file in -next.
