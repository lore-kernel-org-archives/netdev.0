From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netfilter: synproxy: fix sparse errors
Date: Sun, 17 May 2015 14:11:54 -0400 (EDT)
Message-ID: <20150517.141154.1529271828756268845.davem@davemloft.net>
References: <1431706051.27831.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, pablo@netfilter.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbbEQSL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 14:11:56 -0400
In-Reply-To: <1431706051.27831.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 May 2015 09:07:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Fix verbose sparse errors :
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/netfilter/ipt_SYNPROXY.o
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
