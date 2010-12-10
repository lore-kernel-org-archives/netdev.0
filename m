From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] connector: add module alias
Date: Fri, 10 Dec 2010 12:28:13 -0800 (PST)
Message-ID: <20101210.122813.229758283.davem@davemloft.net>
References: <20101209093646.1b5a6abb@nehalam>
	<20101209184746.GA2476@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752853Ab0LJU1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 15:27:45 -0500
In-Reply-To: <20101209184746.GA2476@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Thu, 9 Dec 2010 21:47:46 +0300

> On Thu, Dec 09, 2010 at 09:36:46AM -0800, Stephen Hemminger (shemminger@vyatta.com) wrote:
>> Since connector can be built as a module and uses netlink socket
>> to communicate. The module should have an alias to autoload when socket
>> of NETLINK_CONNECTOR type is requested.
> 
> Ack, thank you.

Please use formalized "Acked-by: " tags so that the automated tools do
all the work for me and I don't have to type it in by hand.

> David, please apply.

Done, thanks.
