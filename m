From: David Miller <davem@davemloft.net>
Subject: Re: =?ISO-8859-1?Q?[net-next-2.6 PATCH] ?= =?ISO-8859-1?Q?e1000e:
 do not modify?= =?ISO-8859-1?Q? tx_queue_len on link?= =?ISO-8859-1?Q?
 speed change?=
Date: Thu, 04 Mar 2010 00:41:28 -0800 (PST)
Message-ID: <20100304.004128.236847399.davem@davemloft.net>
References: <20100303143137.0BCA01220127@host64.kissl.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Brandeburg@host64.kissl.de, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, Allan@host64.kissl.de,
	bruce.w.allan@intel.com
To: franco@lastsummer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754447Ab0CDIlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:41:09 -0500
In-Reply-To: <20100303143137.0BCA01220127@host64.kissl.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: franco@lastsummer.de
Date: Wed,  3 Mar 2010 15:31:37 +0100 (CET)

> e1000e would try to set appropriate values of tx_queue_len for
> negotiated
> link speeds overwriting the already set configuration of tx_queue_len in
> the process. This removes all lines touching tx_queue_len from the
> driver.
> 
> Signed-off-by: Franco Fichtner <franco@lastsummer.de>

Intel folks, you got this?
