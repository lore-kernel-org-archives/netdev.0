From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: add module alias
Date: Fri, 10 Dec 2010 23:44:51 +0300
Message-ID: <20101210204450.GA10790@ioremap.net>
References: <20101209093646.1b5a6abb@nehalam>
 <20101209184746.GA2476@ioremap.net>
 <20101210.122813.229758283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:51821 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757099Ab0LJUox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 15:44:53 -0500
Content-Disposition: inline
In-Reply-To: <20101210.122813.229758283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 12:28:13PM -0800, David Miller (davem@davemloft.net) wrote:
> >> Since connector can be built as a module and uses netlink socket
> >> to communicate. The module should have an alias to autoload when socket
> >> of NETLINK_CONNECTOR type is requested.
> > 
> > Ack, thank you.
> 
> Please use formalized "Acked-by: " tags so that the automated tools do
> all the work for me and I don't have to type it in by hand.

Will do, thanks.

-- 
	Evgeniy Polyakov
