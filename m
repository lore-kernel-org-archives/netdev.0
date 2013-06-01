From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] bnx2x: fix a power state test
Date: Fri, 31 May 2013 17:11:14 -0700 (PDT)
Message-ID: <20130531.171114.1448993396211120979.davem@davemloft.net>
References: <20130531075840.GA28370@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab3FAALP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:11:15 -0400
In-Reply-To: <20130531075840.GA28370@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 31 May 2013 13:07:19 +0300

> PCI_D0 is zero so the original test is never true.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I don't have the hardware to test this, and I'm not positive on it.
> Buyer beware!

Someone please review/test this patch, thanks.
