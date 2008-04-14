From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [TIPC]: Remove redundant socket wait queue
 initialization
Date: Sun, 13 Apr 2008 21:33:53 -0700 (PDT)
Message-ID: <20080413.213353.01710350.davem@davemloft.net>
References: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
	<1207342787-12422-2-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40064
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751146AbYDNEdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 00:33:52 -0400
In-Reply-To: <1207342787-12422-2-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Fri,  4 Apr 2008 16:59:46 -0400

> This patch eliminates re-initialization of the standard socket
> wait queue used for sleeping in TIPC's socket creation code.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied, thanks.
