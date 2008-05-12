From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] [TIPC]: Enhancements to name table
 initialization
Date: Mon, 12 May 2008 15:42:00 -0700 (PDT)
Message-ID: <20080512.154200.257296802.davem@davemloft.net>
References: <1210624383-2175-1-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59394
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755176AbYELWmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 18:42:06 -0400
In-Reply-To: <1210624383-2175-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Mon, 12 May 2008 16:33:03 -0400

> This patch enhances the initialization of TIPC's name table
> by removing a pointless spinlock operation, and by using
> kcalloc() to detect requests for an oversized name table.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
