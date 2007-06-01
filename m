From: David Miller <davem@davemloft.net>
Subject: Re: Fix "ipOutNoRoutes" counter error for TCP and UDP
Date: Thu, 31 May 2007 21:41:04 -0700 (PDT)
Message-ID: <20070531.214104.31597841.davem@davemloft.net>
References: <465E2202.3000607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weidong@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752869AbXFAEku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 00:40:50 -0400
In-Reply-To: <465E2202.3000607@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Dong <weidong@cn.fujitsu.com>
Date: Thu, 31 May 2007 09:16:50 +0800

> Hi Mr. David
>   I have modified my patch according to you advice. I think -
> EHOSTUNREACH is only for "input path". In "output" path, we can just
> simply check-ENETUNREACH  (^_^), the patch is shown in the end of this mail.
> 
>  I send this patch to you several weeks ago, but you have not replied to me.
> This patch is not correctly?

Your email client is still corrupting the patch, it changes
tab characters into spaces.  This makes the patch not apply.

Please do not send the same unusable patch so many times.
Instead, I recommend to email the patch to yourself, and
you try to apply it, in the same way someone else receiving
your patch posting would.

