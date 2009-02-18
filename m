From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/43] drivers/net/ns83820.c: fix sparse warnings: fix
 signedness
Date: Tue, 17 Feb 2009 17:21:39 -0800 (PST)
Message-ID: <20090217.172139.210351923.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211231.23489.52423.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754941AbZBRBVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:21:55 -0500
In-Reply-To: <20090214211231.23489.52423.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:12:36 +0100

> Fix this sparse warnings:
>   drivers/net/ns83820.c:479:36: warning: incorrect type in argument 2 (different signedness)
>   drivers/net/ns83820.c:479:36: warning: incorrect type in argument 2 (different signedness)
>   drivers/net/ns83820.c:479:36: warning: incorrect type in argument 2 (different signedness)
>   drivers/net/ns83820.c:479:36: warning: incorrect type in argument 2 (different signedness)
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
