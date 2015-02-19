From: David Miller <davem@davemloft.net>
Subject: Re: bpf: Enable BPF JIT on ppc32
Date: Thu, 19 Feb 2015 15:56:13 -0500 (EST)
Message-ID: <20150219.155613.1219259214030608341.davem@davemloft.net>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbbBSU4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 15:56:15 -0500
In-Reply-To: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Tue, 17 Feb 2015 10:04:37 +0300

> This patch series enables BPF JIT on ppc32. There are relatevily
> few chnages in the code to make it work.
> 
> All test_bpf tests passed both on 7447a and P2041-based machines.
> 
> Changelog:
> v1 - > v2: Reordered Kconfig patch in the series

Who plans to take this series?  A PowerPC maintainer?

If not, should I take it?
