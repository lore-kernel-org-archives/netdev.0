From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 00/14] tipc: new netlink API
Date: Fri, 21 Nov 2014 15:02:25 -0500 (EST)
Message-ID: <20141121.150225.1810920764527481476.davem@davemloft.net>
References: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbaKUUCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:02:30 -0500
In-Reply-To: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Thu, 20 Nov 2014 10:29:06 +0100

> This is a new netlink API for TIPC. It's intended to replace the
> existing ASCII API. It utilizes many of the standard netlink
> functionalities in the kernel, such as attribute nesting and
> input polices.

Series applied, thanks.
