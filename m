From: David Miller <davem@davemloft.net>
Subject: Re: [patch 07/13] security/selinux/hooks.c: make 4 functions static
Date: Tue, 15 Aug 2006 00:10:24 -0700 (PDT)
Message-ID: <20060815.001024.99733089.davem@davemloft.net>
References: <200608150603.k7F63f8D012942@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23732
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965259AbWHOHKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:10:22 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63f8D012942@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:41 -0700

> From: Adrian Bunk <bunk@stusta.de>
> 
> This patch makes four needlessly global functions static.
> 
> (akpm: applicable to the selinux updates in net-2.6.19.git)
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Acked-by: James Morris <jmorris@namei.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.19
