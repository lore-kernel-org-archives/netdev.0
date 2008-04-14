From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [TIPC]: Improve socket time conversions
Date: Sun, 13 Apr 2008 21:35:36 -0700 (PDT)
Message-ID: <20080413.213536.246711876.davem@davemloft.net>
References: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
	<1207342787-12422-3-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751218AbYDNEff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 00:35:35 -0400
In-Reply-To: <1207342787-12422-3-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Fri,  4 Apr 2008 16:59:47 -0400

> This patch modifies TIPC's socket code to use standard kernel
> routines to handle time conversions between jiffies and ms.
> This ensures proper operation even when HZ isn't 1000.
> 
> Acknowledgements to Eric Sesterhenn <snakebyte@gmx.de> for
> identifying this issue and proposing a solution.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

APplied, thanks Allan.
