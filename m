From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 2/3] ipv6: Export nf_ct_frag6_consume_orig()
Date: Tue, 27 Oct 2015 19:32:48 -0700 (PDT)
Message-ID: <20151027.193248.1129116345115531381.davem@davemloft.net>
References: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
	<1445829710-11292-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, pablo@netfilter.org,
	azhou@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbbJ1CQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:16:07 -0400
In-Reply-To: <1445829710-11292-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Sun, 25 Oct 2015 20:21:49 -0700

> This is needed in openvswitch to fix an skb leak in the next patch.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied.
