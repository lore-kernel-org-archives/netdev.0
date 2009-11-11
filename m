From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: use ipv6_addr_v4mapped()
Date: Tue, 10 Nov 2009 22:34:40 -0800 (PST)
Message-ID: <20091110.223440.146351107.davem@davemloft.net>
References: <4AF89241.7060203@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59212
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752336AbZKKGeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:34:13 -0500
In-Reply-To: <4AF89241.7060203@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Mon, 09 Nov 2009 17:05:53 -0500

> Change udp6_portaddr_hash() to use ipv6_addr_v4mapped()
> inline instead of ipv6_addr_type().
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied to net-next-2.6
