From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/43] drivers/net/e1000e: fix sparse warning: Should
 it be static?
Date: Tue, 17 Feb 2009 17:27:40 -0800 (PST)
Message-ID: <20090217.172740.194379532.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214213152.24377.68475.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49807
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756275AbZBRB1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:27:55 -0500
In-Reply-To: <20090214213152.24377.68475.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:32:25 +0100

> Impact: Make symbol static.
> 
> Fix this sparse warning:
>   drivers/net/e1000e/82571.c:1229:5: warning: symbol 'e1000_check_for_serdes_link_82571' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
