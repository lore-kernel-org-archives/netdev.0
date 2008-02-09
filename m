From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ematch: oops from uninitialized variable (resend)
Date: Sat, 09 Feb 2008 03:48:04 -0800 (PST)
Message-ID: <20080209.034804.51092370.davem@davemloft.net>
References: <20080208175416.50ccdfaa@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59059
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750891AbYBILrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2008 06:47:33 -0500
In-Reply-To: <20080208175416.50ccdfaa@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 8 Feb 2008 17:54:16 -0800

> Setting up a meta match causes a kernel OOPS because of uninitialized
> elements in tree.
...
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied and I'll queue this up for -stable too, thanks!
