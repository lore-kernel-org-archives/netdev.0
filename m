From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: correct debugging message on mii read timeout
Date: Wed, 08 Apr 2009 15:42:22 -0700 (PDT)
Message-ID: <20090408.154222.257721604.davem@davemloft.net>
References: <1239218843-18653-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53085
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754028AbZDHWmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 18:42:32 -0400
In-Reply-To: <1239218843-18653-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Wed,  8 Apr 2009 20:27:23 +0100

> the warning printed when a mii READ times out currently says "Timed out
> waiting for MII write to finish".  This patch corrects this.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
