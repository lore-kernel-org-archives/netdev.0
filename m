From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Tue, 19 Mar 2013 17:26:45 -0400 (EDT)
Message-ID: <20130319.172645.2081434694692631052.davem@davemloft.net>
References: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
	<20130319142141.5d32cae2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933767Ab3CSV0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 17:26:46 -0400
In-Reply-To: <20130319142141.5d32cae2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 19 Mar 2013 14:21:41 -0700

> Doesn't build with this patch alone (ie. not bisectable).
> 
>   CC [M]  net/ipv6/ip6_gre.o
> net/ipv6/ip6_gre.c:41:27: fatal error: net/ip_tunnel.h: No such file or directory
> compilation terminated.

Oh well, too late, it's all already in my tree.
