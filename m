From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: use xfrm_addr_cmp() instead of compare addresses
 directly
Date: Mon, 29 Jun 2009 19:43:34 -0700 (PDT)
Message-ID: <20090629.194334.247050454.davem@davemloft.net>
References: <4A48464D.2010501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55115
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754985AbZF3Cn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:43:28 -0400
In-Reply-To: <4A48464D.2010501@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 29 Jun 2009 12:42:53 +0800

> Clean up to use xfrm_addr_cmp() instead of compare addresses directly.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
