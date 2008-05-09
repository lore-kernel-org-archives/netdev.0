From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [TIPC]: Increase buffer header to support
 worst-case device
Date: Thu, 08 May 2008 21:38:33 -0700 (PDT)
Message-ID: <20080508.213833.108686753.davem@davemloft.net>
References: <1210293242-13387-1-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751446AbYEIEij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 00:38:39 -0400
In-Reply-To: <1210293242-13387-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu,  8 May 2008 20:34:02 -0400

> This patch increases the headroom TIPC reserves in each sk_buff
> to accommodate the largest possible link level device header.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied, thanks Allan.
