From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ALIGN/PTR_ALIGN cleanup in
 alloc_netdev_mq()/netdev_priv()
Date: Wed, 27 May 2009 15:49:58 -0700 (PDT)
Message-ID: <20090527.154958.180974125.davem@davemloft.net>
References: <4A1D515D.90309@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757687AbZE0Wt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 18:49:58 -0400
In-Reply-To: <4A1D515D.90309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 May 2009 16:42:37 +0200

> Use ALIGN() and PTR_ALIGN() macros instead of handcoding them.
> 
> Get rid of NETDEV_ALIGN_CONST ugly define
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6.
