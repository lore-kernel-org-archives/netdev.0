From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] tc: remove unused redirect ttl
Date: Mon, 04 May 2015 00:20:43 -0400 (EDT)
Message-ID: <20150504.002043.739818589191238432.davem@davemloft.net>
References: <1430543983-10446-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, daniel@iogearbox.net, fw@strlen.de,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbEDEUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 00:20:45 -0400
In-Reply-To: <1430543983-10446-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri,  1 May 2015 22:19:43 -0700

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> improves ingress+u32 performance from 22.4 Mpps to 22.9 Mpps
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Acked-by: Florian Westphal <fw@strlen.de>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
