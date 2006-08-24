From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/44] [XFRM] STATE: Introduce route optimization mode.
Date: Wed, 23 Aug 2006 18:00:16 -0700 (PDT)
Message-ID: <20060823.180016.111205658.davem@davemloft.net>
References: <1156345365651-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365264-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365312-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9626
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751031AbWHXBAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:00:13 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <1156345365312-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:09 +0900

> Route optimization is used with routing header and destination options
> header for Mobile IPv6.
> At outbound it makes header space like IPsec transport. At inbound
> it does nothing because exhdrs.c functions have responsibility to
> update skbuff information for these headers.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
