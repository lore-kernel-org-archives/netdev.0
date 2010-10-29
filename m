From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy/marvell: rename 88ec048 to 88e1318s and fix mscr1
 addr
Date: Fri, 29 Oct 2010 13:50:35 -0700 (PDT)
Message-ID: <20101029.135035.179931517.davem@davemloft.net>
References: <1288280112-622-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cyril@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756557Ab0J2UuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 16:50:12 -0400
In-Reply-To: <1288280112-622-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyril Chemparathy <cyril@ti.com>
Date: Thu, 28 Oct 2010 11:35:12 -0400

> The marvell 88ec048's official part number is 88e1318s.  This patch renames
> definitions in the driver to reflect this.
> 
> In addition, a minor bug fix has been added to write back the MSCR1 register
> value properly.
> 
> Signed-off-by: Cyril Chemparathy <cyril@ti.com>

Applied, thank you.
