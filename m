From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 19:58:55 -0700 (PDT)
Message-ID: <20100323.195855.00471034.davem@davemloft.net>
References: <1269377667.2915.25.camel@edumazet-laptop>
	<20100323.144512.140757007.davem@davemloft.net>
	<80769D7B14936844A23C0C43D9FBCF0F254E49AC69@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754507Ab0CXC6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 22:58:33 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F254E49AC69@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Tue, 23 Mar 2010 15:08:12 -0700

> I'll do some digging on this to see what I can find out.

Please see:  http://vger.kernel.org/jamal_netconf2006.sxi
