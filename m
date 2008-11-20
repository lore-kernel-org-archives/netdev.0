From: David Miller <davem@davemloft.net>
Subject: Re: pkt_sched 01/02: remove unnecessary xchg() in packet schedulers
Date: Thu, 20 Nov 2008 04:11:46 -0800 (PST)
Message-ID: <20081120.041146.152650204.davem@davemloft.net>
References: <492454DA.5080306@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43457
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754747AbYKTMLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:11:46 -0500
In-Reply-To: <492454DA.5080306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 19 Nov 2008 19:03:06 +0100

> commit 7f23be11b3d23ca23822a3e65b7eda10ec129e9a
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Nov 19 18:58:17 2008 +0100
> 
>     pkt_sched: remove unnecessary xchg() in packet schedulers
>     
>     The use of xchg() hasn't been necessary since 2.2.something when proper
>     locking was added to packet schedulers.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
