From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sun, 18 Jan 2009 22:08:35 -0800 (PST)
Message-ID: <20090118.220835.122143858.davem@davemloft.net>
References: <20090115234255.GE1123@1wt.eu>
	<20090115234408.GA1693@1wt.eu>
	<20090116065107.GA4170@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, herbert@gondor.apana.org.au, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755774AbZASGIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 01:08:34 -0500
In-Reply-To: <20090116065107.GA4170@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 16 Jan 2009 06:51:08 +0000

> David, if it's not too late I think more credits are needed,
> especially for Willy. He did "a bit" more than testing.
 ...
> Foreseen-by: Changli Gao <xiaosuo@gmail.com>
> Diagnosed-by: Willy Tarreau <w@1wt.eu>
> Reported-by: Willy Tarreau <w@1wt.eu>
> Fixed-by: Jens Axboe <jens.axboe@oracle.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

I will be sure to add these before committing, thanks Jarek.
