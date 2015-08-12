From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 28/31] net/xfrm: use kmemdup rather than duplicating its
 implementation
Date: Wed, 12 Aug 2015 12:25:25 +0200
Message-ID: <20150812102525.GB25499@secunet.com>
References: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
 <1438934377-4922-29-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43980 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643AbbHLKZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 06:25:30 -0400
Content-Disposition: inline
In-Reply-To: <1438934377-4922-29-git-send-email-a.hajda@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 07, 2015 at 09:59:34AM +0200, Andrzej Hajda wrote:
> The patch was generated using fixed coccinelle semantic patch
> scripts/coccinelle/api/memdup.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2014320
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Applied to ipsec-next, thanks!
