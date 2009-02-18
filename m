From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/43] drivers/net/arcnet: fix sparse warning: symbol
 shadows an earlier one
Date: Tue, 17 Feb 2009 17:26:41 -0800 (PST)
Message-ID: <20090217.172641.192893096.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211439.23489.20716.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54454
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755289AbZBRB05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:26:57 -0500
In-Reply-To: <20090214211439.23489.20716.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:14:45 +0100

> Impact: Remove redundant inner scope variable.
> 
> Fix this sparse warning:
>   drivers/net/arcnet/arcnet.c:383:21: warning: symbol 'count' shadows an earlier one
>   drivers/net/arcnet/arcnet.c:375:13: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
