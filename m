From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock_diag: add SK_MEMINFO_BACKLOG
Date: Mon, 04 Jun 2012 11:33:39 -0400 (EDT)
Message-ID: <20120604.113339.1505758528166894264.davem@davemloft.net>
References: <1338817835.2760.1815.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760783Ab2FDPdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:33:43 -0400
In-Reply-To: <1338817835.2760.1815.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Jun 2012 15:50:35 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Adding socket backlog len in INET_DIAG_SKMEMINFO is really useful to
> diagnose various TCP problems.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
