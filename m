From: David Miller <davem@davemloft.net>
Subject: Re: [patch 05/11] bonding: Replace kmalloc() + memset() pairs with
 the appropriate kzalloc() calls
Date: Tue, 06 Feb 2007 14:17:28 -0800 (PST)
Message-ID: <20070206.141728.102615064.davem@davemloft.net>
References: <200702060032.l160W7hH004630@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkmaillist@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965573AbXBFWRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:17:54 -0500
In-Reply-To: <200702060032.l160W7hH004630@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:31:04 -0800

> From: "Joe Jin" <lkmaillist@gmail.com>
> 
> Replace kmalloc() + memset() pairs with the appropriate kzalloc() calls in
> the bonding driver.
> 
> Signed-off-by: Joe Jin <lkmaillist@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Jeff asked me to take this so I have, applied, thanks.
