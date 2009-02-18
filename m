From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/43] drivers/net/hamradio: fix sparse warnings: fix
 signedness
Date: Tue, 17 Feb 2009 17:38:39 -0800 (PST)
Message-ID: <20090217.173839.30296316.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214213543.24377.50515.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47197
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755215AbZBRBiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:38:54 -0500
In-Reply-To: <20090214213543.24377.50515.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:36:20 +0100

> Fix this sparse warnings:
>   drivers/net/hamradio/hdlcdrv.c:274:34: warning: incorrect type in argument 2 (different signedness)
>   drivers/net/hamradio/hdlcdrv.c:279:47: warning: incorrect type in argument 2 (different signedness)
>   drivers/net/hamradio/hdlcdrv.c:288:39: warning: incorrect type in argument 2 (different signedness)
>   drivers/net/hamradio/hdlcdrv.c:300:47: warning: incorrect type in argument 2 (different signedness)
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
