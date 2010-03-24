From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 23:10:05 -0700 (PDT)
Message-ID: <20100323.231005.254851368.davem@davemloft.net>
References: <80769D7B14936844A23C0C43D9FBCF0F254E49AC69@orsmsx501.amr.corp.intel.com>
	<20100323.195855.00471034.davem@davemloft.net>
	<1269409324.2915.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36736
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754592Ab0CXGJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:09:42 -0400
In-Reply-To: <1269409324.2915.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Mar 2010 06:42:04 +0100

> Do we have a list of such network related documents ?

Not really, just scan http://vger.kernel.org/netconf200${N}.html
for the papers :-)
