From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7 net-2.6.26] [TIPC]: Add argument validation for
 shutdown()
Date: Thu, 06 Mar 2008 15:05:45 -0800 (PST)
Message-ID: <20080306.150545.212585595.davem@davemloft.net>
References: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
	<1204839269-30593-3-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59776
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756165AbYCFXFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:05:45 -0500
In-Reply-To: <1204839269-30593-3-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu,  6 Mar 2008 16:34:24 -0500

> This patch validates that the "how" argument to shutdown()
> is SHUT_RDWR, since this is the only form that TIPC supports.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
