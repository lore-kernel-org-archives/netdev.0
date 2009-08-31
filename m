From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Sun, 30 Aug 2009 22:32:39 -0700 (PDT)
Message-ID: <20090830.223239.185830289.davem@davemloft.net>
References: <20090826215956.GA5148@ami.dom.local>
	<20090830.220559.77181973.davem@davemloft.net>
	<20090831053026.GA5005@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41159
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751012AbZHaFcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 01:32:25 -0400
In-Reply-To: <20090831053026.GA5005@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 31 Aug 2009 05:30:27 +0000

> Actually, I think now, after 2.6.31, this patch might be a bit too
> late. If people hit this problem they probably should've fixed it
> until -next already, so let's forget about this patch until there are
> more such reports.

Ok.

> Btw, I guess, Denys could submit some warnings into iproute's code
> and/or documentation, as he proposed earlier.

Yeah sounds like a good idea.
