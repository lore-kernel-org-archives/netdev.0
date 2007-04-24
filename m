From: David Miller <davem@davemloft.net>
Subject: Re: [BNX2]: Fix occasional NETDEV WATCHDOG on 5709.
Date: Tue, 24 Apr 2007 15:36:23 -0700 (PDT)
Message-ID: <20070424.153623.24101440.davem@davemloft.net>
References: <1177455465.4812.20.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423184AbXDXWgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 18:36:16 -0400
In-Reply-To: <1177455465.4812.20.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 24 Apr 2007 15:57:45 -0700

> [BNX2]: Fix occasional NETDEV WATCHDOG on 5709.
> 
> Tweak a register setting to prevent the tx mailbox from halting.
> 
> Update version to 1.5.8.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
