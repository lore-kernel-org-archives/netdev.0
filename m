From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 26/27] drivers/net/wireless/ipw2x00: fix sparse
 warnings: make symbols static
Date: Fri, 26 Dec 2008 00:14:47 -0800 (PST)
Message-ID: <20081226.001447.234645995.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191851.11807.885.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753282AbYLZIOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 03:14:45 -0500
In-Reply-To: <20081222191851.11807.885.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 22 Dec 2008 20:18:51 +0100

> Fix this sparse warnings:
> 
>   drivers/net/wireless/ipw2x00/ipw2100.c:5271:6: warning: symbol 'ipw2100_queues_initialize' was not declared. Should it be static?
>   drivers/net/wireless/ipw2x00/ipw2100.c:5278:6: warning: symbol 'ipw2100_queues_free' was not declared. Should it be static?
>   drivers/net/wireless/ipw2x00/ipw2100.c:5285:5: warning: symbol 'ipw2100_queues_allocate' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
