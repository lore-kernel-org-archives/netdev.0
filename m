From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/43] drivers/net/s2io.c: fix sparse warning: symbol
 shadows an earlier one
Date: Tue, 17 Feb 2009 17:22:25 -0800 (PST)
Message-ID: <20090217.172225.175747063.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211423.23489.10245.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54448
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755691AbZBRBWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:22:41 -0500
In-Reply-To: <20090214211423.23489.10245.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:14:31 +0100

> Impact: Remove redundant inner scope variable.
> 
> Fix this sparse warning:
>   drivers/net/s2io.c:7223:21: warning: symbol 'i' shadows an earlier one
>   drivers/net/s2io.c:7184:13: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
