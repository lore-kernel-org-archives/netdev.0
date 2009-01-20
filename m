From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: annotate bp->phy_lock functions
Date: Mon, 19 Jan 2009 17:27:18 -0800 (PST)
Message-ID: <20090119.172718.91842721.davem@davemloft.net>
References: <1232395910.13386.4.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751080AbZATB1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 20:27:16 -0500
In-Reply-To: <1232395910.13386.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 19 Jan 2009 12:11:50 -0800

> It looks like the locking is OK as the locks were being taken before the
> various phy setup functions, add the annotations as they release and
> reacquire the phy_lock.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Queued up for 2.6.30, thanks Harvey.
