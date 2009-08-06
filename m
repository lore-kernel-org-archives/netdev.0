From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] tc35815: Disable StripCRC
Date: Thu, 06 Aug 2009 13:16:30 -0700 (PDT)
Message-ID: <20090806.131630.238661796.davem@davemloft.net>
References: <1249569709-21403-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42430
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932172AbZHFUQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 16:16:20 -0400
In-Reply-To: <1249569709-21403-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Thu,  6 Aug 2009 23:41:45 +0900

> It seems Rx_StripCRC cause trouble on recovering from the BLEx (Buffer
> List Exhaust) or FDAEx (Free Descriptor Area Exhaust) condition.
> Do not use it.
> 
> Also bump version number up.
> 
> Reported-by: Ralf Roesch <ralf.roesch@rw-gmbh.de>
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied to net-next-2.6
