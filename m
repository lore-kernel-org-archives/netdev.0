From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: better error reporting
Date: Wed, 07 Oct 2015 02:59:14 -0700 (PDT)
Message-ID: <20151007.025914.747216135875784160.davem@davemloft.net>
References: <E1ZiQJ1-0003q8-78@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, linux@roeck-us.net
To: rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbbJGJna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 05:43:30 -0400
In-Reply-To: <E1ZiQJ1-0003q8-78@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Sat, 03 Oct 2015 18:09:07 +0100

> Add additional error reporting to the generic DSA code, so it's easier
> to debug when things go wrong.  This was useful when initially bringing
> up 88e6176 on a new board.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied.
