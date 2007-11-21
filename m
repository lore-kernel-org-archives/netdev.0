From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [IPV4] TCPMD5: Use memmove() instead of memcpy()
 because we have overlaps.
Date: Tue, 20 Nov 2007 17:30:37 -0800 (PST)
Message-ID: <20071120.173037.128572692.davem@davemloft.net>
References: <20071121.015128.16115326.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756792AbXKUBai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:30:38 -0500
In-Reply-To: <20071121.015128.16115326.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 21 Nov 2007 01:51:28 +0900 (JST)

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
