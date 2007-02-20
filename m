From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/irda/: proper prototypes
Date: Tue, 20 Feb 2007 01:05:50 -0800 (PST)
Message-ID: <20070220.010550.108740097.davem@davemloft.net>
References: <200702060031.l160VuqL004621@shell0.pdx.osdl.net>
	<20070205.180142.35665788.davem@davemloft.net>
	<20070220000720.GR13958@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	samuel@sortiz.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50668
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbXBTJFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 04:05:52 -0500
In-Reply-To: <20070220000720.GR13958@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 20 Feb 2007 01:07:21 +0100

> On Mon, Feb 05, 2007 at 06:01:42PM -0800, David Miller wrote:
> > From: akpm@linux-foundation.org
> > Date: Mon, 05 Feb 2007 16:30:53 -0800
> > 
> > > From: Adrian Bunk <bunk@stusta.de>
> > > 
> > > Add proper prototypes for some functions in include/net/irda/irda.h
> > > 
> > > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > > Acked-by: Samuel Ortiz <samuel@sortiz.org>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > I NAK'd this so that Adrian would go add "extern" to the
> > function declarations in the header file.
> > 
> > Please drop this, Adrian will resend once he fixes it up.
> 
> Sorry, I should have sent this earlier.
> Updated patch below.
 ...
> This patch adds proper prototypes for some functions in
> include/net/irda/irda.h
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Thanks Adrian, applied.
