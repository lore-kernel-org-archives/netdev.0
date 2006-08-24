From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/44] [XFRM] STATE: Allow non IPsec protocol.
Date: Wed, 23 Aug 2006 17:50:17 -0700 (PDT)
Message-ID: <20060823.175017.75431039.davem@davemloft.net>
References: <11563453651533-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453653169-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365325-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53214
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965280AbWHXAuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:50:15 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <1156345365325-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:04 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> It will be added two more transformation protocols (routing header
> and destination options header) for Mobile IPv6.
> xfrm_id_proto_match() can be handle zero as all, IPSEC_PROTO_ANY as
> all IPsec and otherwise as exact one.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied to net-2.6.19, thanks a lot.
