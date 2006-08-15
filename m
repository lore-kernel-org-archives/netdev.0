From: David Miller <davem@davemloft.net>
Subject: Re: [patch 08/13] netfilter: make unused signal code go away so
 nobody copies its brokenness
Date: Tue, 15 Aug 2006 00:10:44 -0700 (PDT)
Message-ID: <20060815.001044.77405065.davem@davemloft.net>
References: <200608150603.k7F63geM012945@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk, alan@redhat.com,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26804
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965261AbWHOHKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:10:43 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63geM012945@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:42 -0700

> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> 
> This code is wrong on so many levels, please lose it so it isn't replicated
> anywhere else.
> 
> Signed-off-by: Alan Cox <alan@redhat.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.19
