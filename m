From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kernel-doc fixes for net/
Date: Thu, 26 Jul 2007 00:03:52 -0700 (PDT)
Message-ID: <20070726.000352.11598552.davem@davemloft.net>
References: <20070723214219.b50a0d1b.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40622
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760157AbXGZHDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 03:03:53 -0400
In-Reply-To: <20070723214219.b50a0d1b.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 23 Jul 2007 21:42:19 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix kernel-doc omissions in net/:
> 
> Warning(linux-2.6.23-rc1//net/core/dev.c:2728): No description found for parameter 'addr'
> Warning(linux-2.6.23-rc1//net/core/dev.c:2752): No description found for parameter 'addr'
> Warning(linux-2.6.23-rc1//net/core/dev.c:3839): No description found for parameter 'net_dma'
> Warning(linux-2.6.23-rc1//net/core/dev.c:3877): No description found for parameter 'state'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
