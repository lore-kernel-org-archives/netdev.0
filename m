From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 36/43] drivers/net/wan: fix sparse warning: symbol
 shadows an earlier one
Date: Tue, 17 Feb 2009 19:35:24 -0800 (PST)
Message-ID: <20090217.193524.111535677.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214214815.24377.92862.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754469AbZBRDfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:35:40 -0500
In-Reply-To: <20090214214815.24377.92862.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:48:25 +0100

> Impact: Rename function scope variable and while being at it fix some
> coding style issues.
> 
> Fix this sparse warning:
>   drivers/net/wan/sbni.c:1526:14: warning: symbol 'num' shadows an earlier one
>   drivers/net/wan/sbni.c:160:13: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
