From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/r8169: Update the function of parsing firmware
Date: Mon, 10 Jan 2011 16:14:02 -0800 (PST)
Message-ID: <20110110.161402.236235481.davem@davemloft.net>
References: <1294661245-2191-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54364
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753358Ab1AKAN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 19:13:29 -0500
In-Reply-To: <1294661245-2191-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 10 Jan 2011 20:07:25 +0800

> Update rtl_phy_write_fw function. The new function could
> parse the complex firmware which is used by RTL8111E and later.
> The new firmware may read data and do some operations, not just
> do writing only.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thank you.
