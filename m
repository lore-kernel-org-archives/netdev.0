From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 42/43] drivers/net/wireless/ipw2x00: fix sparse
 warnings: fix signedness
Date: Tue, 17 Feb 2009 19:49:39 -0800 (PST)
Message-ID: <20090217.194939.168796459.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214215013.24377.69151.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754189AbZBRDty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:49:54 -0500
In-Reply-To: <20090214215013.24377.69151.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:50:26 +0100

> Fix this sparse warnings:
>   drivers/net/wireless/ipw2x00/ipw2100.c:1930:43: warning: incorrect type in argument 4 (different signedness)
>   drivers/net/wireless/ipw2x00/ipw2100.c:1938:76: warning: incorrect type in argument 4 (different signedness)
>   drivers/net/wireless/ipw2x00/ipw2100.c:1946:67: warning: incorrect type in argument 4 (different signedness)
>   drivers/net/wireless/ipw2x00/ipw2100.c:1953:72: warning: incorrect type in argument 4 (different signedness)
>   drivers/net/wireless/ipw2x00/ipw2100.c:4071:73: warning: incorrect type in argument 4 (different signedness)
>   drivers/net/wireless/ipw2x00/ipw2100.c:4078:43: warning: incorrect type in argument 4 (different signedness)
>   drivers/net/wireless/ipw2x00/ipw2100.c:4084:67: warning: incorrect type in argument 4 (different signedness)
>   drivers/net/wireless/ipw2x00/ipw2100.c:7141:73: warning: incorrect type in argument 4 (different signedness)
>   drivers/net/wireless/ipw2x00/ipw2100.c:8317:48: warning: incorrect type in argument 4 (different signedness)
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
