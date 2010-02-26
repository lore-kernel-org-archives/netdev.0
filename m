From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Remove IPV6_ADDR_RESERVED
Date: Fri, 26 Feb 2010 03:59:52 -0800 (PST)
Message-ID: <20100226.035952.27099373.davem@davemloft.net>
References: <20100226092858.GA5986@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uweber@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935641Ab0BZL7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 06:59:34 -0500
In-Reply-To: <20100226092858.GA5986@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <uweber@astaro.com>
Date: Fri, 26 Feb 2010 10:28:58 +0100

> RFC 4291 section 2.4 states that all uncategorized addresses
> should be considered as Global Unicast.
> 
> This will remove IPV6_ADDR_RESERVED completely
> and return IPV6_ADDR_UNICAST in ipv6_addr_type() instead.
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>

Applied.
