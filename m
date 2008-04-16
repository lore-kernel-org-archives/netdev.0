From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7 net-2.6.26] [TIPC]: Cleanup of TIPC reference table
 code
Date: Tue, 15 Apr 2008 19:00:51 -0700 (PDT)
Message-ID: <20080415.190051.66156328.davem@davemloft.net>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
	<1208288637-15304-4-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46855
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752812AbYDPCAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:00:50 -0400
In-Reply-To: <1208288637-15304-4-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 15 Apr 2008 15:43:53 -0400

> This patch is a largely cosmetic cleanup of the TIPC reference
> table code.  Variable naming has been made more consistent,
> useless #includes have been eliminated, and the object reference
> field in each table entry is no longer implemented using an
> unnecessary structure union.  In addition, error checking has
> been enhanced to detect accidental access to reference table
> entries that are on the free list.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Dropping because it depends upon patch #1 and #2 which
won't be applied.
