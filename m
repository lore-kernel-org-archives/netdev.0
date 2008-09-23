From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] drivers/isdn/capi/kcapi.c: Adjust error handling
 code involving capi_ctr_put
Date: Mon, 22 Sep 2008 19:05:36 -0700 (PDT)
Message-ID: <20080922.190536.158404509.davem@davemloft.net>
References: <200809222151.m8MLp1S9031895@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, netdev@vger.kernel.org, julia@diku.dk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34971
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753951AbYIWCFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:05:48 -0400
In-Reply-To: <200809222151.m8MLp1S9031895@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:51:01 -0700

> After calling capi_ctr_get, error handling code should call capi_ctr_put.
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Cc: Karsten Keil <kkeil@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6, thanks.
