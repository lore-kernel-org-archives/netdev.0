From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] inet: tcp listener refactoring, part 8
Date: Thu, 12 Mar 2015 22:59:02 -0400 (EDT)
Message-ID: <20150312.225902.346508150299996301.davem@davemloft.net>
References: <1426203850-11034-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbbCMC7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 22:59:04 -0400
In-Reply-To: <1426203850-11034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 12 Mar 2015 16:44:02 -0700

> These patches prepare request socks being hashed into general ehash
> table : We declare 3 aliases (ireq_state, ireq_refcnt, ireq_family)
> 
> Note that refcnt is not yet handled, this will be done later.

Looks good, series applied, thanks Eric!
