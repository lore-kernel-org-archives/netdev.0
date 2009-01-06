From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] irda: convert to internal stats
Date: Tue, 06 Jan 2009 10:41:10 -0800 (PST)
Message-ID: <20090106.104110.207291330.davem@davemloft.net>
References: <20090105201442.749889072@vyatta.com>
	<20090105201514.192918670@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34925
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751029AbZAFSlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 13:41:09 -0500
In-Reply-To: <20090105201514.192918670@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 05 Jan 2009 12:14:43 -0800

> Convert IRDA drivers to use already existing net_device_stats structure
> in network device. This is a pre-cursor to conversion to net_device
> ops. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
