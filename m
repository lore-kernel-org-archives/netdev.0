From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [IrDA] Monitor mode
Date: Mon, 02 Jul 2007 22:55:43 -0700 (PDT)
Message-ID: <20070702.225543.122680771.davem@davemloft.net>
References: <20070701221427.101308704@sortiz.org>
	<20070701221705.413124168@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754804AbXGCFzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 01:55:23 -0400
In-Reply-To: <20070701221705.413124168@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: samuel@sortiz.org
Date: Mon, 02 Jul 2007 01:14:29 +0300

> Through the IrDA netlink set mode command, we switch to IrDA monitor mode,
> where one IrLAP instance receives all the packets on the media, without ever
> responding to them.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks.
