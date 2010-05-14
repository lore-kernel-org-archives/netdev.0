From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: Remove unnecessary returns from
 void function()s
Date: Thu, 13 May 2010 19:09:53 -0700 (PDT)
Message-ID: <20100513.190953.233716325.davem@davemloft.net>
References: <1273606224.20514.295.camel@Joe-Laptop.home>
	<1273769886.21514.72.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751250Ab0ENCJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 22:09:45 -0400
In-Reply-To: <1273769886.21514.72.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 13 May 2010 09:58:06 -0700

> fyi: Patrick McHardy prefers null statement void functions to
> keep the return.
> 
> There are some more removals of return like this in the patch.
> If a new patch should be generated, do tell.

Ok, please remake this patch with those cases removed.

Thanks Joe.

