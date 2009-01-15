From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Thu, 15 Jan 2009 15:54:34 -0800 (PST)
Message-ID: <20090115.155434.206643894.davem@davemloft.net>
References: <20090115.153449.204259387.davem@davemloft.net>
	<20090115234255.GE1123@1wt.eu>
	<20090115234408.GA1693@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44446
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753787AbZAOXyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 18:54:33 -0500
In-Reply-To: <20090115234408.GA1693@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 16 Jan 2009 00:44:08 +0100

> And BTW feel free to add my Tested-by if you want in case you merge
> this fix.

Done, thanks Willy.
