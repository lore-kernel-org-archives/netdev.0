From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] sk_nulls_next_rcu
Date: Mon, 30 Nov 2009 16:24:54 -0800 (PST)
Message-ID: <20091130.162454.119309341.davem@davemloft.net>
References: <200912010219.29340.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43937
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753149AbZLAAYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 19:24:48 -0500
In-Reply-To: <200912010219.29340.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 1 Dec 2009 02:19:29 +0200

> 
> I am trying to convert the LLC code to RCU, and it appears that for proc 
> support a sk_nulls_next_rcu would be required. 
> 
> Is this the wrong way to do it, or is it that nobody need it yet?

I think simply nobody needed it yet.

Eric, please take a look at Octavian's patch, thanks!
