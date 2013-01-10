From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] doc: Clarify behavior when sysctl tcp_ecn = 1
Date: Thu, 10 Jan 2013 14:40:05 -0800 (PST)
Message-ID: <20130110.144005.1409444774954325906.davem@davemloft.net>
References: <1357770090-29253-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, rick.jones2@hp.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231Ab3AJWkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:40:05 -0500
In-Reply-To: <1357770090-29253-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Wed,  9 Jan 2013 14:21:30 -0800

> Recent commit (commit 7e3a2dc52953 doc: make the description of how tcp_ecn
> works more explicit and clear ) clarified the behavior of tcp_ecn sysctl
> variable but description is inconsistent. When requested by incoming conections,
> ECN is enabled with not just tcp_ecn = 2 but also with tcp_ecn = 1.
> 
> This patch makes it clear that with tcp_ecn = 1, ECN is enabled when requested
> by incoming connections.
> 
> Also fix spelling of 'incoming'.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Applied.
