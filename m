From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] net/mlx4_en: fix stats
Date: Wed, 25 May 2016 22:17:13 -0700 (PDT)
Message-ID: <20160525.221713.1376891009998911224.davem@davemloft.net>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, eugenia@mellanox.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbcEZFRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 01:17:15 -0400
In-Reply-To: <1464195039-5098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 25 May 2016 09:50:35 -0700

> mlx4 has various bugs in its ndo_get_stats() and related functions.
> This patch series address the obvious issues.
> Remaining ones will be discussed later.

Series applied, thanks.
