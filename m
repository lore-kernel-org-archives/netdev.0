From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][KEY] fix bug in spdadd
Date: Thu, 14 Feb 2008 14:53:07 -0800 (PST)
Message-ID: <20080214.145307.59327251.davem@davemloft.net>
References: <47B42C3C.5090104@miyazawa.org>
	<20080215.015405.121725938.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53609
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752988AbYBNWwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 17:52:35 -0500
In-Reply-To: <20080215.015405.121725938.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 15 Feb 2008 01:54:05 +1100 (EST)

> [PATCH] [XFRM]: Avoid bogus BUG() when throwing new policy away.
> 
> When we destory a new policy entry, we need to tell
> xfrm_policy_destroy() explicitly that the entry is not
> alive yet.

Applied.

Please provide a proper Signed-off-by: next time.

Thank you!
