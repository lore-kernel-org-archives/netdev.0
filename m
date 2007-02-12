From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3] tcp: use read mostly for CUBIC parameters
Date: Mon, 12 Feb 2007 13:15:43 -0800 (PST)
Message-ID: <20070212.131543.75431187.davem@davemloft.net>
References: <20070212160317.545906075@linux-foundation.org>
	<20070212160336.527416565@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41780
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965417AbXBLVPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 16:15:45 -0500
In-Reply-To: <20070212160336.527416565@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Feb 2007 08:03:19 -0800

> These module parameters should be in the read mostly area
> to avoid cache pollution.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
