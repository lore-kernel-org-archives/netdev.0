From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/43] drivers/net/niu.c: fix sparse warning: symbol
 shadows an earlier one
Date: Tue, 17 Feb 2009 17:21:44 -0800 (PST)
Message-ID: <20090217.172144.27843428.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211244.23489.31564.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755243AbZBRBV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:21:59 -0500
In-Reply-To: <20090214211244.23489.31564.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:12:48 +0100

> Impact: Move variable declaration to a more inner scope.
> 
> Fix this sparse warning:
>   drivers/net/niu.c:2399:21: warning: symbol 'err' shadows an earlier one
>   drivers/net/niu.c:2287:13: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
