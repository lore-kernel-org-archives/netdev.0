From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] ipv6: convert tunnels to net_device_ops
Date: Thu, 20 Nov 2008 20:34:04 -0800 (PST)
Message-ID: <20081120.203404.234197141.davem@davemloft.net>
References: <20081120175913.943543638@vyatta.com>
	<20081120175934.215776511@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59511
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752552AbYKUEeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 23:34:05 -0500
In-Reply-To: <20081120175934.215776511@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 20 Nov 2008 09:59:21 -0800

> Like IPV4, convert the tunnel virtual devices to use net_device_ops.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

