From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net/xfrm/xfrm_policy.c: Some small improvements
Date: Thu, 06 Dec 2007 03:14:34 -0800 (PST)
Message-ID: <20071206.031434.179419183.davem@davemloft.net>
References: <20071206110123.GB2469@hacking>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	akpm@osdl.org, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751461AbXLFLOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 06:14:34 -0500
In-Reply-To: <20071206110123.GB2469@hacking>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WANG Cong <xiyou.wangcong@gmail.com>
Date: Thu, 6 Dec 2007 19:01:23 +0800

> 
> This patch contains the following changes.
> 
> 	- Use 'bool' instead of 'int' for booleans.
> 	- Use 'size_t' instead of 'int' for 'sizeof' return value.
> 	- Some style fixes.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

Normally I would let a patch like this sit in my mailbox
for a week and then delete it.

But this time I'll just let you know up front that I
don't see much value in this patch.  It is not a clear
improvement to replace int's with bool's in my mind and
the other changes are just whitespace changes.

And thus I can delete the patch from my mailbox
immediately :-)

Sorry.
