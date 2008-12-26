From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/27] drivers/net/atlx: fix sparse warnings: make
 symbols static
Date: Thu, 25 Dec 2008 23:58:41 -0800 (PST)
Message-ID: <20081225.235841.230537795.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191544.11807.31114.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37912
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752802AbYLZH6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 02:58:38 -0500
In-Reply-To: <20081222191544.11807.31114.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 22 Dec 2008 20:15:45 +0100

> Fix this sparse warnings:
> 
>   drivers/net/atlx/atl1.c:198:16: warning: symbol 'atl1_check_options' was not declared. Should it be static?
>   drivers/net/atlx/atl1.c:526:5: warning: symbol 'atl1_read_mac_addr' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
