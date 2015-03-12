From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] inet: tcp listener refactoring, part 8
Date: Thu, 12 Mar 2015 18:46:50 -0400 (EDT)
Message-ID: <20150312.184650.448363850529742427.davem@davemloft.net>
References: <1426197016-14482-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbbCLWqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:46:51 -0400
In-Reply-To: <1426197016-14482-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 12 Mar 2015 14:50:09 -0700

> These patches prepare request socks being hashed into general ehash
> table : We declare 3 aliases (ireq_state, ireq_refcnt, ireq_family)
> 
> Note that refcnt is not yet handled, this will be done later.

Other than the changes I'd like you to split out from patch #2 this
series looks fine to me.

Nice work!
