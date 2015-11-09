From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] net: add skb_to_full_sk() helper
Date: Sun, 08 Nov 2015 20:56:57 -0500 (EST)
Message-ID: <20151108.205657.1930349537386279969.davem@davemloft.net>
References: <1447008853-16060-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, paul@paul-moore.com,
	casey@schaufler-ca.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbbKIB47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 20:56:59 -0500
In-Reply-To: <1447008853-16060-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun,  8 Nov 2015 10:54:06 -0800

> Many contexts need to reach listener socket from skb attached
> to a request socket. This patch series add skb_to_full_sk() to
> clearly express this need and use it where appropriate.

Series applied, thanks Eric.
