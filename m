From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] [IPV6]: Policy Routing Rules
Date: Wed, 26 Jul 2006 15:42:53 -0700 (PDT)
Message-ID: <20060726.154253.129339483.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221850.124450582@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41413
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751809AbWGZWmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 18:42:52 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726221850.124450582@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Jul 2006 00:00:04 +0200

> Adds support for policy routing rules including a new
> local table for routes with a local destination.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

With the generic fib_rules this is straightforward,
looks good.

Signed-off-by: David S. Miller <davem@davemloft.net>
