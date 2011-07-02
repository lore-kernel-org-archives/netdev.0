From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] xfrm: Remove family arg from xfrm_bundle_ok
Date: Fri, 01 Jul 2011 17:34:24 -0700 (PDT)
Message-ID: <20110701.173424.819314860244878604.davem@davemloft.net>
References: <20110630091820.GB13201@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab1GBAem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 20:34:42 -0400
In-Reply-To: <20110630091820.GB13201@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 30 Jun 2011 11:18:20 +0200

> The family arg is not used any more, so remove it.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
