From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/27] drivers/net/wan: fix sparse warning: make symbol
 static
Date: Fri, 26 Dec 2008 00:11:27 -0800 (PST)
Message-ID: <20081226.001127.216496763.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191804.11807.55143.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750752AbYLZILZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 03:11:25 -0500
In-Reply-To: <20081222191804.11807.55143.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 22 Dec 2008 20:18:04 +0100

> Fix this sparse warning:
> 
>   drivers/net/wan/x25_asy.c:623:5: warning: symbol 'x25_asy_esc' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
