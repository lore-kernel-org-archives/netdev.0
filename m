From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] KEY: Fix conversion between IPSEC_MODE_xxx and
 XFRM_MODE_xxx.
Date: Tue, 17 Apr 2007 12:38:51 -0700 (PDT)
Message-ID: <20070417.123851.56978012.davem@davemloft.net>
References: <20070417.171517.53528528.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kazunori@miyazawa.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37379
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031159AbXDQTit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 15:38:49 -0400
In-Reply-To: <20070417.171517.53528528.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Tue, 17 Apr 2007 17:15:17 +0900 (JST)

> From: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
> Subject: [PATCH] KEY: Fix conversion between IPSEC_MODE_xxx and XFRM_MODE_xxx.
> 
> We should not blindly convert between IPSEC_MODE_xxx and XFRM_MODE_xxx just
> by incrementing / decrementing because the assumption is not true any longer.
> 
> Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
> Singed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied, thank you.
