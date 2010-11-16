From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v4)
Date: Tue, 16 Nov 2010 10:25:37 -0800 (PST)
Message-ID: <20101116.102537.246547550.davem@davemloft.net>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
	<1289416194-1844-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754817Ab0KPSZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 13:25:14 -0500
In-Reply-To: <1289416194-1844-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nhorman@tuxdriver.com
Date: Wed, 10 Nov 2010 14:09:54 -0500

> Version 4 of this patch.

Applied, thanks a lot for doing this.
