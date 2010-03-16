From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: wait for PHY to complete reset during init
Date: Tue, 16 Mar 2010 14:28:54 -0700 (PDT)
Message-ID: <20100316.142854.189438468.davem@davemloft.net>
References: <1268766186-16014-1-git-send-email-steve.glendinning@smsc.com>
	<1268766186-16014-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758032Ab0CPV2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:28:32 -0400
In-Reply-To: <1268766186-16014-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 16 Mar 2010 19:03:06 +0000

> This patch ensures the PHY correctly completes its reset before
> setting register values.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
