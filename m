From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] skbuff.h: fix timestamps kernel-doc
Date: Mon, 02 Mar 2009 03:16:07 -0800 (PST)
Message-ID: <20090302.031607.206653959.davem@davemloft.net>
References: <20090227104638.5b4f8f6e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752205AbZCBLQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:16:25 -0500
In-Reply-To: <20090227104638.5b4f8f6e.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 27 Feb 2009 10:46:38 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix skbuff.h kernel-doc for timestamps: must include "struct" keyword,
> otherwise there are kernel-doc errors:
> 
> Error(linux-next-20090227//include/linux/skbuff.h:161): cannot understand prototype: 'struct skb_shared_hwtstamps '
> Error(linux-next-20090227//include/linux/skbuff.h:177): cannot understand prototype: 'union skb_shared_tx '
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
