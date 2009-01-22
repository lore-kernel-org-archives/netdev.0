From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] phy: Add suspend/resume support to SMSC PHYs
Date: Thu, 22 Jan 2009 14:07:51 -0800 (PST)
Message-ID: <20090122.140751.123274634.davem@davemloft.net>
References: <1232622145-4730-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42794
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753205AbZAVWHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:07:49 -0500
In-Reply-To: <1232622145-4730-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 22 Jan 2009 11:02:25 +0000

> All supported SMSC PHYs implement the standard "power down" bit 11 of
> BMCR, so this patch adds support using the generic genphy_{suspend,resume}
> functions.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied, thanks Steve.
