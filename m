From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] ROUTE: Assign rt6i_idev for
 ip6_{prohibit,blk_hole}_entry.
Date: Wed, 09 May 2007 01:45:30 -0700 (PDT)
Message-ID: <20070509.014530.88343895.davem@davemloft.net>
References: <20070509.170550.81965404.yoshfuji@linux-ipv6.org>
	<20070509.011333.122833121.davem@davemloft.net>
	<20070509.174228.18186896.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755916AbXEIIpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 04:45:30 -0400
In-Reply-To: <20070509.174228.18186896.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 09 May 2007 17:42:28 +0900 (JST)

> Wait for a moment, please.
> I thought it should fix the issue, but
> I must say, the fix does not seem sufficient...
> 
> I'm now analysing further.

Ok, I'll tell -stable to hold on this patch.
