From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add macro for printing mac addresses
Date: Fri, 15 Feb 2008 02:58:55 -0800 (PST)
Message-ID: <20080215.025855.202184003.davem@davemloft.net>
References: <20080215104804.9870.15722.stgit@one>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com
To: bruno@thinktube.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756063AbYBOK6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 05:58:22 -0500
In-Reply-To: <20080215104804.9870.15722.stgit@one>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruno Randolf <bruno@thinktube.com>
Date: Fri, 15 Feb 2008 19:48:05 +0900

> is there any chance to include a macro like this for printing mac addresses?
> 
> its advantage is that it can be used without the need to declare buffers for
> print_mac(), for example:
> 
> printk("mac address: " MAC_FMT, MAC_ADDR(addr));
> 
> Signed-off-by: Bruno Randolf <bruno@thinktube.com>

We specifically removed this sort of thing, please don't
add it back.

Thank you.
