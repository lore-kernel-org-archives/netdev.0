From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 23/27] drivers/net/wireless: fix sparse warnings: make
 symbols static
Date: Fri, 26 Dec 2008 00:13:11 -0800 (PST)
Message-ID: <20081226.001311.218715858.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191823.11807.62915.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753303AbYLZINI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 03:13:08 -0500
In-Reply-To: <20081222191823.11807.62915.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 22 Dec 2008 20:18:23 +0100

> Fix this sparse warnings:
> 
>   drivers/net/wireless/airo.c:3610:6: warning: symbol 'mpi_receive_802_11' was not declared. Should it be static?
>   drivers/net/wireless/atmel.c:3183:6: warning: symbol 'atmel_join_bss' was not declared. Should it be static?
>   drivers/net/wireless/ray_cs.c:831:5: warning: symbol 'ray_dev_init' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
