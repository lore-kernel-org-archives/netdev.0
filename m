From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] be2net: bug fix in be_change_mtu
Date: Fri, 12 Feb 2010 12:29:23 -0800 (PST)
Message-ID: <20100212.122923.262000564.davem@davemloft.net>
References: <20100209113233.GA10485@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52527
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757622Ab0BLU3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:29:08 -0500
In-Reply-To: <20100209113233.GA10485@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Tue, 9 Feb 2010 17:02:43 +0530

> Current code allows the new mtu to cross the supported value.
> This patch fixes the boundary checks.
> 
> From: Suresh R <sureshr@serverengines.com>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied to net-next-2.6
