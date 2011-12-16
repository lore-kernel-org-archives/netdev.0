From: David Miller <davem@davemloft.net>
Subject: Re: nonlocal_bind and IPv6
Date: Fri, 16 Dec 2011 13:18:33 -0500 (EST)
Message-ID: <20111216.131833.2127398230815526406.davem@davemloft.net>
References: <m3zket9gqj.fsf@neo.luffy.cx>
	<20111216.020600.1695776769736304587.davem@davemloft.net>
	<e21a2d9682b5d83fefe3f09a07316033@luffy.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: bernat@luffy.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760133Ab1LPSUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:20:45 -0500
In-Reply-To: <e21a2d9682b5d83fefe3f09a07316033@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <bernat@luffy.cx>
Date: Fri, 16 Dec 2011 10:53:48 +0100

> Moreover, I am just adding the IPv6 version of this setting. The IPv4
> version already exists.

I don't think the ipv4 feature was a wise thing to add, so just because
ipv4 has something doesn't automatically make it appropriate to support
it in ipv6 too.  So please don't use arguments like that.
