From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4vf: fix SGE resource resource deallocation bug
Date: Thu, 15 Jul 2010 22:47:16 -0700 (PDT)
Message-ID: <20100715.224716.57481347.davem@davemloft.net>
References: <201007151554.43269.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32896
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758718Ab0GPFrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 01:47:00 -0400
In-Reply-To: <201007151554.43269.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Thu, 15 Jul 2010 15:54:43 -0700

>>From 1ecf246196c43d75e75525211450a64d650f4fbc Mon Sep 17 00:00:00 2001
> From: Casey Leedom <leedom@chelsio.com>
> Date: Thu, 15 Jul 2010 15:50:16 -0700
> Subject: [PATCH] cxgb4vf: fix SGE resource resource deallocation bug
> 
> Fix SGE resource resource deallocation bug.  Forgot to increment the RXQ and
> TXQ cursors in the loop ...
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied, thanks Casey.
