From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/43] drivers/net/cxgb3: fix sparse warning: symbol
 shadows an earlier one
Date: Tue, 17 Feb 2009 17:27:15 -0800 (PST)
Message-ID: <20090217.172715.248316017.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211557.23489.75670.stgit@vmbox.hanneseder.net>
	<4998897A.3030904@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@hanneseder.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54469
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753026AbZBRB1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:27:31 -0500
In-Reply-To: <4998897A.3030904@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Sun, 15 Feb 2009 13:30:34 -0800

> Hannes Eder wrote:
> > Impact: Move variable declaration as close to usage as possible.
> >
> > Fix this sparse warning:
> >   drivers/net/cxgb3/cxgb3_main.c:1586:21: warning: symbol 'cap' shadows an earlier one
> >
> > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> >   
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied.
