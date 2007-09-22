From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 19:47:17 -0700
Message-ID: <1190429237.4957.6.camel@dell>
References: <200709211201.24475.vda.linux@googlemail.com>
 <20070921.091432.74736040.davem@davemloft.net>
 <200709211803.55554.vda.linux@googlemail.com>
 <20070921.104912.41646795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: vda.linux@googlemail.com, jeff@garzik.org,
	linux-kernel@vger.kernel.org, "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3780 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962AbXIVBtE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 21:49:04 -0400
In-Reply-To: <20070921.104912.41646795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-09-21 at 10:49 -0700, David Miller wrote:
> From: Denys Vlasenko <vda.linux@googlemail.com>
> Date: Fri, 21 Sep 2007 18:03:55 +0100
> 
> > Do patches look ok to you?
> 
> I'm travelling so I haven't looked closely yet :-)
> 
> Michael can take a look and I'll try to do so as well
> tonight.
> 

I've already reviewed the earlier versions of the patch and have made
some suggestions.  This latest one looks ok to me and tested ok.

I'll follow up later with another patch to remove all the zeros in other
firmware sections, and to remove the gzip headers completely.

Acked-by: Michael Chan <mchan@broadcom.com>

