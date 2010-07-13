From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4vf: fix TX Queue restart
Date: Mon, 12 Jul 2010 20:32:56 -0700 (PDT)
Message-ID: <20100712.203256.43024261.davem@davemloft.net>
References: <201007121502.54176.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41414
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751868Ab0GMDcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:32:41 -0400
In-Reply-To: <201007121502.54176.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Mon, 12 Jul 2010 15:02:53 -0700

>>From e1c7a6e339a47c42aaf3e425fa3228b33a425a8f Mon Sep 17 00:00:00 2001
> From: Casey Leedom <leedom@chelsio.com>
> Date: Mon, 12 Jul 2010 14:39:07 -0700
> Subject: [PATCH net-next] cxgb4vf: fix TX Queue restart
> 
> Fix up TX Queue Host Flow Control to cause an Egress Queue Status Update to
> be generated when we run out of TX Queue Descriptors.  This will, in turn,
> allow us to restart a stopped TX Queue.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied, thanks.
