From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Fix a bug in preparation of mcc wrb which was
 causing flash operation to fail
Date: Mon, 05 Oct 2009 02:09:48 -0700 (PDT)
Message-ID: <20091005.020948.261557950.davem@davemloft.net>
References: <20091005090555.GA12287@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43695
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751180AbZJEJJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:09:53 -0400
In-Reply-To: <20091005090555.GA12287@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Mon, 5 Oct 2009 14:36:07 +0530

> This patch fixes a bug that got introduced in commit 76998bc7.
> During preparation of mcc wrb, req was being wrongly overwritten
> and the flash operation was failing.
> This patch is against the net-2.6 tree.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied, thanks.
