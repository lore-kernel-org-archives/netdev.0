From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net sched: printk message severity
Date: Mon, 17 May 2010 22:58:07 -0700 (PDT)
Message-ID: <20100517.225807.22051427.davem@davemloft.net>
References: <20100512163704.780058547@vyatta.com>
	<20100512163719.414013223@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56017
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755828Ab0ERF57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:57:59 -0400
In-Reply-To: <20100512163719.414013223@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 12 May 2010 09:37:05 -0700

> The previous patch encourage me to go look at all the messages in
> the network scheduler and fix them. Many messages were missing
> any severity level. Some serious ones that should never happen
> were turned into WARN(), and the random noise messages that were
> handled changed to pr_debug().
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
