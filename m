From: David Miller <davem@davemloft.net>
Subject: Re: netfilter: ctnetlink: fix missing CTA_NAT_SEQ_UNSPEC
Date: Tue, 16 Dec 2008 01:20:18 -0800 (PST)
Message-ID: <20081216.012018.196068498.davem@davemloft.net>
References: <49467ACC.8080107@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49467ACC.8080107@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 15 Dec 2008 16:42:04 +0100

> following is a single netfilter patch for 2.6.28, fixing incorrect
> ctnetlink NAT attribute definitions that break common userspace
> attribute parsing code.
> 
> Please apply, thanks.

Applied, thanks Patrick.
