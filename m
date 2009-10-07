From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: mark net_proto_ops as const
Date: Wed, 07 Oct 2009 01:30:00 -0700 (PDT)
Message-ID: <20091007.013000.260052327.davem@davemloft.net>
References: <20091003104004.GA15919@elte.hu>
	<20091004.211107.184509170.davem@davemloft.net>
	<20091005085839.2b3f82df@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933975AbZJGIaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:30:05 -0400
In-Reply-To: <20091005085839.2b3f82df@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 5 Oct 2009 08:58:39 -0700

> All usages of structure net_proto_ops should be declared const.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
