From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] net: fix kernel-doc warning in core/filter.c
Date: Sun, 09 Jan 2011 16:27:06 -0800 (PST)
Message-ID: <20110109.162706.13747432.davem@davemloft.net>
References: <20110108194142.22a0c3d8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54570
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753298Ab1AJA0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 19:26:34 -0500
In-Reply-To: <20110108194142.22a0c3d8.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Sat, 8 Jan 2011 19:41:42 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix new kernel-doc notation warning in net/core/filter.c:
> 
> Warning(net/core/filter.c:172): No description found for parameter 'fentry'
> Warning(net/core/filter.c:172): Excess function parameter 'filter' description in 'sk_run_filter'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied.
