From: David Miller <davem@davemloft.net>
Subject: Re: MTU blackhole discovery for IPv6 ?
Date: Thu, 07 May 2009 14:48:05 -0700 (PDT)
Message-ID: <20090507.144805.138068252.davem@davemloft.net>
References: <20090507211926.GA28662@regulus.madore.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david+ml@madore.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50643
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751119AbZEGVsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:48:10 -0400
In-Reply-To: <20090507211926.GA28662@regulus.madore.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Madore <david+ml@madore.org>
Date: Thu, 7 May 2009 23:19:26 +0200

> There's a sysctl called net.ipv4.tcp_mtu_probing: has there been any
> work done on the analogous key for IPv6?

Just because the sysctl only appears under ipv4/ doesn't mean
that it only controls ipv4 operations.

This applies to all of the TCP controls especially.

