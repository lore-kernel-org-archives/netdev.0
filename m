From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][NET] gen_estimator: list_empty() check in
 est_timer() fixed
Date: Mon, 21 Jan 2008 03:15:53 -0800 (PST)
Message-ID: <20080121.031553.224463409.davem@davemloft.net>
References: <20080121064240.GB981@ff.dom.local>
	<20080121.023632.122420355.davem@davemloft.net>
	<20080121111940.GF1789@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, slavon@bigtelecom.ru,
	kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38964
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754801AbYAULPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 06:15:48 -0500
In-Reply-To: <20080121111940.GF1789@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 21 Jan 2008 12:19:40 +0100

> On Mon, Jan 21, 2008 at 02:36:32AM -0800, David Miller wrote:
> ...
> > FWIW I agree that double-negatives are confusing and we should
> > avoid them.
> 
> Right! No more: CHECKSUM_NONE, SOCK_NOSPACE, IFF_NOARP or KERN_NOTICE!

Life is difficult sometimes, but that is no excuse to further
the pain :-)

