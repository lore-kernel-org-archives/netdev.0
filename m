From: David Miller <davem@davemloft.net>
Subject: Re: [patch 08/11] slip: Replace kmalloc() + memset() pairs with
 the appropriate kzalloc() calls
Date: Mon, 05 Feb 2007 18:08:55 -0800 (PST)
Message-ID: <20070205.180855.84974650.davem@davemloft.net>
References: <200702060032.l160W99K004640@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe.jin@oracle.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965431AbXBFCIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:08:55 -0500
In-Reply-To: <200702060032.l160W99K004640@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:31:06 -0800

> From: joe jin <joe.jin@oracle.com>
> 
> This patch replace kmalloc() + memset() pairs with the appropriate
> kzalloc().
> 
> Signed-off-by: Joe Jin <joe.jin@oracle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
