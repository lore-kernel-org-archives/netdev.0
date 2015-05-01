From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Fri, 1 May 2015 10:57:25 +0200
Message-ID: <20150501085725.GB1164@breakpoint.cc>
References: <1430449896-5406-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41029 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751995AbbEAI5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 04:57:31 -0400
Content-Disposition: inline
In-Reply-To: <1430449896-5406-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <ast@plumgrid.com> wrote:
> improves ingress+u32 performance from 22.4 Mpps to 22.9 Mpps
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> The code is from Jamal. I only did testing and benchmarking.

I had similar patch, so
Acked-by: Florian Westphal <fw@strlen.de>
