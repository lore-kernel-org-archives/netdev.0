From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v8 1/2] net: implement mechanism for HW
 based QOS
Date: Wed, 19 Jan 2011 23:41:32 -0800 (PST)
Message-ID: <20110119.234132.176672734.davem@davemloft.net>
References: <20110117175542.29543.38690.stgit@jf-dev1-dcblab>
	<20110117180604.29543.38660.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jarkao2@gmail.com, hadi@cyberus.ca,
	eric.dumazet@gmail.com, shemminger@vyatta.com, tgraf@infradead.org,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49907
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752194Ab1ATHk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 02:40:59 -0500
In-Reply-To: <20110117180604.29543.38660.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 17 Jan 2011 10:06:04 -0800

> This patch provides a mechanism for lower layer devices to
> steer traffic using skb->priority to tx queues.
 ...
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
