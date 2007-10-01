From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Sun, 30 Sep 2007 17:57:26 -0700 (PDT)
Message-ID: <20070930.175726.48827024.davem@davemloft.net>
References: <200709211803.55554.vda.linux@googlemail.com>
	<20070921.104912.41646795.davem@davemloft.net>
	<1190429237.4957.6.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vda.linux@googlemail.com, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58673
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbXJAA50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 20:57:26 -0400
In-Reply-To: <1190429237.4957.6.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 21 Sep 2007 19:47:17 -0700

> On Fri, 2007-09-21 at 10:49 -0700, David Miller wrote:
> > From: Denys Vlasenko <vda.linux@googlemail.com>
> > Date: Fri, 21 Sep 2007 18:03:55 +0100
> > 
> > > Do patches look ok to you?
> > 
> > I'm travelling so I haven't looked closely yet :-)
> > 
> > Michael can take a look and I'll try to do so as well
> > tonight.
> > 
> 
> I've already reviewed the earlier versions of the patch and have made
> some suggestions.  This latest one looks ok to me and tested ok.
> 
> I'll follow up later with another patch to remove all the zeros in other
> firmware sections, and to remove the gzip headers completely.
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

I've added these patches to net-2.6.24, thanks.
