From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bpf/filter updates
Date: Wed, 11 Dec 2013 20:37:27 -0500 (EST)
Message-ID: <20131211.203727.54128433042539652.davem@davemloft.net>
References: <1386801825-15388-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364Ab3LLBh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:37:29 -0500
In-Reply-To: <1386801825-15388-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 11 Dec 2013 23:43:42 +0100

> This set adds just two minimal helper tools that complement the
> already available bpf_jit_disasm and complete BPF tooling; plus
> it adds and an extensive documentation update of filter.txt.
> 
> Please see individual descriptions for details.

This looks fantastic, thanks for doing this work.

Series applied.
