From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/44] [IPV6] MIP6: Add socket option and ancillary
 data interface of routing header type 2.
Date: Wed, 23 Aug 2006 19:17:43 -0700 (PDT)
Message-ID: <20060823.191743.57158045.davem@davemloft.net>
References: <1156345366676-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453662840-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453662913-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20909
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030200AbWHXCRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:17:40 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453662913-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:22 +0900

> Add socket option and ancillary data interface of routing header type 2.
> Mobile IPv6 application will use this to send binding acknowledgement
> with the header without relation of confirmed route optimization (binding).
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
