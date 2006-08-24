From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/44] [XFRM] STATE: Add source address list.
Date: Wed, 23 Aug 2006 17:54:36 -0700 (PDT)
Message-ID: <20060823.175436.28791154.davem@davemloft.net>
References: <1156345365325-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453653851-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453653575-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55774
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965309AbWHXAye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:54:34 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453653575-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:06 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> Support source address based searching.
> Mobile IPv6 will use it.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied to net-2.6.19, thanks a lot.

I see this is where I will need to perform conflict resolution
with my XFRM layer hashing patches :-)
