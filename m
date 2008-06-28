From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv6 route: Convert rt6_device_match() to use
 RT6_LOOKUP_F_xxx flags.
Date: Fri, 27 Jun 2008 20:15:05 -0700 (PDT)
Message-ID: <20080627.201505.01490207.davem@davemloft.net>
References: <20080628.014714.86911438.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752053AbYF1DPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 23:15:05 -0400
In-Reply-To: <20080628.014714.86911438.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sat, 28 Jun 2008 01:47:14 +0900 (JST)

> The commit 77d16f450ae0452d7d4b009f78debb1294fb435c ("[IPV6] ROUTE:
> Unify RT6_F_xxx and RT6_SELECT_F_xxx flags") intended to pass various
> routing lookup hints around RT6_LOOKUP_F_xxx flags, but conversion was
> missing for rt6_device_match().
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6, thanks!
