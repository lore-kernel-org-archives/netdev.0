From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] STATE: Fix flusing with hash mask.
Date: Thu, 31 Aug 2006 15:15:38 -0700 (PDT)
Message-ID: <20060831.151538.28807746.davem@davemloft.net>
References: <20060825232819.66C6.NAKAM@linux-ipv6.org>
	<20060825.154717.38711346.davem@davemloft.net>
	<200608312100.17307.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7326
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964797AbWHaWPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:15:32 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <200608312100.17307.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Thu, 31 Aug 2006 21:00:17 +0900

> This is a minor fix about transformation state flushing
> for net-2.6.19. Please apply it.

Thank you for finding this bug.  Patch applied.

Masahide-san, please provide a Signed-off-by: line in
the future, even for simple changes like this one.

Arigato.

