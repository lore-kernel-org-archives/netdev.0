From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: improve source port selection
Date: Thu, 21 May 2015 18:55:51 -0400 (EDT)
Message-ID: <20150521.185551.1197920450569579445.davem@davemloft.net>
References: <1432144742-17786-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbbEUWzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:55:52 -0400
In-Reply-To: <1432144742-17786-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 20 May 2015 10:59:00 -0700

> With increase of TCP sockets in hosts, we often hit limitations
> caused by port selection, due to randomization and poor strategy.

This looks fine, nice work, applied.

Thanks Eric!
