From: David Miller <davem@davemloft.net>
Subject: Re: bpf: Enable BPF JIT on ppc32
Date: Fri, 20 Feb 2015 15:20:21 -0500 (EST)
Message-ID: <20150220.152021.2226608147725066444.davem@davemloft.net>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbbBTUUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:20:24 -0500
In-Reply-To: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aFrom: Denis Kirjanov <kda@linux-powerpc.org>
Date: Tue, 17 Feb 2015 10:04:37 +0300

> This patch series enables BPF JIT on ppc32. There are relatevily
> few chnages in the code to make it work.
> 
> All test_bpf tests passed both on 7447a and P2041-based machines.
> 
> Changelog:
> v1 - > v2: Reordered Kconfig patch in the series

Series applied to net-next, thanks.
