From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Log the affected address when DAD failure occurs
Date: Thu, 17 Sep 2009 10:24:30 -0700 (PDT)
Message-ID: <20090917.102430.172893626.davem@davemloft.net>
References: <1253101477.10715.8.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: me@jayr.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751402AbZIQRYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 13:24:13 -0400
In-Reply-To: <1253101477.10715.8.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rosenboom <me@jayr.de>
Date: Wed, 16 Sep 2009 13:44:37 +0200

> From: Jens Rosenboom <me@jayr.de>
> 
> If an interface has multiple addresses, the current message for DAD
> failure isn't really helpful, so this patch adds the address itself to
> the printk.
> 
> Signed-off-by: Jens Rosenboom <me@jayr.de>

Applied.
