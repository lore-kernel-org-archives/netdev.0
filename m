From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 36/44] [XFRM]: Introduce XFRM_MSG_REPORT.
Date: Wed, 23 Aug 2006 23:53:02 -0700 (PDT)
Message-ID: <20060823.235302.74749546.davem@davemloft.net>
References: <11563453672531-git-send-email-yoshfuji@linux-ipv6.org>
	<20060823.204352.123974654.davem@davemloft.net>
	<44ED4BAA.1040106@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64976
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030362AbWHXGxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 02:53:12 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44ED4BAA.1040106@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Thu, 24 Aug 2006 15:48:10 +0900

> Should I start to design it?

Thank you for the analysis.

Let's not jump so quickly towards implementation just
yet.

What I plan to do right now is port my XFRM hashing patches into the
current net-2.6.19 tree.

I am hoping that, in the mean time, maybe someone such as Jamal,
Thomas Graf, or Herbert Xu might have some opinion in the area
of AEVENT and XFRM_MSG_REPORT.
