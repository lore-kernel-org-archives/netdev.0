From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 23/43] drivers/net/igb: fix sparse warning: symbol
 shadows an earlier one
Date: Tue, 17 Feb 2009 17:39:03 -0800 (PST)
Message-ID: <20090217.173903.121180042.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214213628.24377.69119.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47200
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755795AbZBRBjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:39:18 -0500
In-Reply-To: <20090214213628.24377.69119.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:38:08 +0100

> Impact: Move variable declaration as far inner as possible.
> 
> Fix this sparse warning:
>   drivers/net/igb/igb_main.c:1895:21: warning: symbol 'j' shadows an earlier one
>   drivers/net/igb/igb_main.c:1855:16: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

There have been some changes recently to the igb driver so
this patch no longer applies.
