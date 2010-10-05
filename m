From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] wimax: make functions local
Date: Tue, 05 Oct 2010 00:48:39 -0700 (PDT)
Message-ID: <20101005.004839.232894591.davem@davemloft.net>
References: <20101005145959.362fbd85@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: inaky@linux.intel.com, linux-wimax@vger.kernel.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54748
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756056Ab0JEHsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:48:19 -0400
In-Reply-To: <20101005145959.362fbd85@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 5 Oct 2010 14:59:59 +0900

> Make wimax variables and functions local if possible.
> Compile tested only.
> 
> This also removes a couple of unused EXPORT_SYMBOL.
> If this breaks some out of tree code, please fix that
> by putting the code in the kernel tree.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
