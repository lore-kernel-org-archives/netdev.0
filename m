From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: teql_enqueue can check limits before skb enqueue
Date: Tue, 08 May 2007 18:57:58 -0700 (PDT)
Message-ID: <20070508.185758.126762870.davem@davemloft.net>
References: <20070508073124.17543.7859.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S968801AbXEIB56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 21:57:58 -0400
In-Reply-To: <20070508073124.17543.7859.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Tue, 08 May 2007 13:01:24 +0530

> Optimize teql_enqueue so that it first checks limits before
> enqueing.
> 
> Patch against net-2.6.22.git
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied, thanks.
