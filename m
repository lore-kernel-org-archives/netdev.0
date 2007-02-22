From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use random32() in net/ipv4/multipath
Date: Thu, 22 Feb 2007 01:26:49 -0800 (PST)
Message-ID: <20070222.012649.119274047.davem@davemloft.net>
References: <1171583205.29021.44.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37195
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751527AbXBVJ0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 04:26:50 -0500
In-Reply-To: <1171583205.29021.44.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 15 Feb 2007 15:46:44 -0800

> Einar Lueck's email addresses bounce
> <elueck@de.ibm.com><lkml@einar-lueck.de>
> 
> Removed local random number generator function
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
