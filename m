From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: fix unused variable warning
Date: Mon, 10 Mar 2014 15:32:49 -0400 (EDT)
Message-ID: <20140310.153249.1371677500636016810.davem@davemloft.net>
References: <1394233063.20149.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbaCJTcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:32:51 -0400
In-Reply-To: <1394233063.20149.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Mar 2014 14:57:43 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> net/l2tp/l2tp_core.c:1111:15: warning: unused variable
> 'sk' [-Wunused-variable]
> 
> Fixes: 31c70d5956fc ("l2tp: keep original skb ownership")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
