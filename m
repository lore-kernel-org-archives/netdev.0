From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Marvell 88E1118 interrupt fix
Date: Mon, 26 Jan 2009 12:21:32 -0800 (PST)
Message-ID: <20090126.122132.106851564.davem@davemloft.net>
References: <1232741050-6960-1-git-send-email-ron_madrid@sbcglobal.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron_madrid@sbcglobal.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751959AbZAZUVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:21:30 -0500
In-Reply-To: <1232741050-6960-1-git-send-email-ron_madrid@sbcglobal.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Madrid <ron_madrid@sbcglobal.net>
Date: Fri, 23 Jan 2009 12:04:10 -0800

> This patch adjusts the LED control so that interrupt lines are not reading LEDs
> and effectively causing indefinite interrupts to the controller.
> 
> Signed-off-by: Ron Madrid <ron_madrid@sbcglobal.net>

There is no drivers/net/tsec.c in the tree.  I can't even find
'phy_info_M88E1118' in any source file.

What are you generating this patch against?
