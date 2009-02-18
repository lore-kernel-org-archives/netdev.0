From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/43] drivers/net/cxgb3: fix sparse warnings: fix
 signedness
Date: Tue, 17 Feb 2009 17:27:27 -0800 (PST)
Message-ID: <20090217.172727.80119726.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211612.23489.60993.stgit@vmbox.hanneseder.net>
	<499889D7.2070305@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@hanneseder.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49803
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756177AbZBRB1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:27:43 -0500
In-Reply-To: <499889D7.2070305@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Sun, 15 Feb 2009 13:32:07 -0800

> Hannes Eder wrote:
> > Fix this sparse warning:
> >   drivers/net/cxgb3/ael1002.c:1010:60: warning: incorrect type in argument 4 (different signedness)
> >
> > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> >   
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied.
