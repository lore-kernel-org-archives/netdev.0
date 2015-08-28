From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: don't break line in tc_classify
 loop notification
Date: Fri, 28 Aug 2015 14:01:32 -0700 (PDT)
Message-ID: <20150828.140132.733705536483533562.davem@davemloft.net>
References: <4b24d2566b1877613540f277e60673c817b71842.1440780286.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbbH1VBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 17:01:33 -0400
In-Reply-To: <4b24d2566b1877613540f277e60673c817b71842.1440780286.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 28 Aug 2015 18:46:39 +0200

> Just some minor noise follow-up to address some stylistic issues of
> commit 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}").
> Accidentally v1 instead of v2 of that commit got applied, so this
> patch adds the relative diff.
> 
> Suggested-by: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
