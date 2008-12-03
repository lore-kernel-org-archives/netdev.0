From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] xfrm: Cleanup for unlink SPD entry
Date: Wed, 03 Dec 2008 00:33:27 -0800 (PST)
Message-ID: <20081203.003327.258430682.davem@davemloft.net>
References: <20081201081111.GA19615@gondor.apana.org.au>
	<20081201.003821.42061993.davem@davemloft.net>
	<4933B488.3000406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58684
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbYLCNYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 08:24:23 -0500
In-Reply-To: <4933B488.3000406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 01 Dec 2008 17:55:20 +0800

> Used __xfrm_policy_unlink() to instead of the dup codes when unlink
> SPD entry.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

I forwarded ported this to net-next-2.6 and added it there.

Thanks!
