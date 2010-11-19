From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] X25: remove bkl in routing ioctls
Date: Fri, 19 Nov 2010 12:41:16 -0800 (PST)
Message-ID: <20101119.124116.245405599.davem@davemloft.net>
References: <1290122495.20070.63.camel@jaunty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52991
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755315Ab0KSUku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 15:40:50 -0500
In-Reply-To: <1290122495.20070.63.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Fri, 19 Nov 2010 10:21:35 +1100

> 
> Routing doesn't use the socket data and is protected by x25_route_list_lock
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
