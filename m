From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/17] Misc MIPS/BPF fixes for 3.16
Date: Mon, 23 Jun 2014 12:49:19 -0700 (PDT)
Message-ID: <20140623.124919.2215480222213445820.davem@davemloft.net>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, dborkman@redhat.com, ast@plumgrid.com,
	netdev@vger.kernel.org
To: markos.chandras@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbaFWTtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 15:49:23 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markos Chandras <markos.chandras@imgtec.com>
Date: Mon, 23 Jun 2014 10:38:43 +0100

> Here are some fixes for MIPS/BPF for 3.16. These fixes make
> the bpf testsuite *almost* happy with only 2 tests (LD_IND_LL,
> LD_IND_NET) failing at the moment. Since fixing the remaining tests
> is not so trivial, it would be nice to have these fixes in 3.16 for now.
> 
> The patches are based on the upstream-sfr/mips-for-linux-next tree
> because they depend on https://patchwork.linux-mips.org/patch/7099/

You did not CC: netdev on patches 1, 2, and 3.  Please do not do this,
people on this list will want to review the series as a whole.
