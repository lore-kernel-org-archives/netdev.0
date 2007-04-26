From: David Miller <davem@davemloft.net>
Subject: Re: [patch 13/15] irda_device_dongle_init: fix kzalloc(GFP_KERNEL)
 in spinlock
Date: Thu, 26 Apr 2007 01:36:57 -0700 (PDT)
Message-ID: <20070426.013657.90119415.davem@davemloft.net>
References: <200704260727.l3Q7RZr7023981@shell0.pdx.osdl.net>
	<kjNEPme1.1177575167.3331050.samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	matthias.kaehlcke@gmail.com
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56509
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933465AbXDZIgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:36:49 -0400
In-Reply-To: <kjNEPme1.1177575167.3331050.samuel@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Samuel Ortiz" <samuel@sortiz.org>
Date: 26 Apr 2007 08:12:47 -0000

> 
> On 4/26/2007, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
> wrote:
> 
> >From: Andrew Morton <akpm@linux-foundation.org>
> >
> >Fix http://bugzilla.kernel.org/show_bug.cgi?id=8343
> >
> >Cc: Samuel Ortiz <samuel@sortiz.org>
> >Cc: <matthias.kaehlcke@gmail.com>
> >Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> This one was on my pipeline, looks good to me.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied.
