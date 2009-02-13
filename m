From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c505: do not set pcb->data.raw beyond its size
Date: Thu, 12 Feb 2009 16:52:43 -0800 (PST)
Message-ID: <20090212.165243.42415462.davem@davemloft.net>
References: <20090211205854.GB2550@ami.dom.local>
	<4993576C.8080409@gmail.com>
	<20090212063715.GA4283@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, philb@gnu.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754005AbZBMAwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:52:49 -0500
In-Reply-To: <20090212063715.GA4283@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 12 Feb 2009 06:37:15 +0000

> On Wed, Feb 11, 2009 at 11:55:40PM +0100, Roel Kluin wrote:
> > Many thanks, Jarek,
> > 
> > Is this changelog ok?
> 
> Yes, the changelog and patch look OK to me.

Applied, thanks everyone.
