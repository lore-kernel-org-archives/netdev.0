From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v8 2/2] net_sched: implement a root
 container qdisc sch_mqprio
Date: Wed, 19 Jan 2011 23:41:42 -0800 (PST)
Message-ID: <20110119.234142.67886150.davem@davemloft.net>
References: <20110117175542.29543.38690.stgit@jf-dev1-dcblab>
	<20110117180609.29543.54616.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jarkao2@gmail.com, hadi@cyberus.ca,
	eric.dumazet@gmail.com, shemminger@vyatta.com, tgraf@infradead.org,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752881Ab1ATHlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 02:41:09 -0500
In-Reply-To: <20110117180609.29543.54616.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 17 Jan 2011 10:06:09 -0800

> This implements a mqprio queueing discipline that by default creates
> a pfifo_fast qdisc per tx queue and provides the needed configuration
> interface.
 ...
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
