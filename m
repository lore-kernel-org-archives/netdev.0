From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sit: fix an oops when IFLA_IPTUN_PROTO is not
 set
Date: Wed, 19 Jun 2013 22:15:12 -0700 (PDT)
Message-ID: <20130619.221512.1883226884020973402.davem@davemloft.net>
References: <1371636193-4612-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab3FTFPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 01:15:12 -0400
In-Reply-To: <1371636193-4612-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 19 Jun 2013 12:03:13 +0200

> The use of this attribute has been added in 32b8a8e59c9c (sit: add IPv4 over
> IPv4 support). It is optional, by default proto is IPPROTO_IPV6.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
