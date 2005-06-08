From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/1] sysctl configurable icmperror sourceaddress
Date: Wed, 08 Jun 2005 14:49:41 -0700 (PDT)
Message-ID: <20050608.144941.26530856.davem@davemloft.net>
References: <1118136384.10479.15.camel@jeroens.office.netland.nl>
	<20050608214540.GF28207@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: buytenh@wantstofly.org
In-Reply-To: <20050608214540.GF28207@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Wed, 8 Jun 2005 23:45:40 +0200

> Can this patch go in, pretty please?
> 
> Here's the patch again for reference:

We have a similar sysctl for ARP handling, why don't
we make use of it?
