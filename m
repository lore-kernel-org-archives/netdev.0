From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] add statistics
Date: Sat, 12 Jan 2008 21:23:45 -0800 (PST)
Message-ID: <20080112.212345.91038058.davem@davemloft.net>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.583836190@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42407
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751222AbYAMFXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 00:23:46 -0500
In-Reply-To: <20080112064646.583836190@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 11 Jan 2008 22:45:21 -0800

> The FIB TRIE code has a bunch of statistics, but the code is hidden
> behind an ifdef that was never implemented. Since it was dead code,
> it was broken as well.
> 
> This patch fixes that by making it a config option.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

Applied, thanks.
