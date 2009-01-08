From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 32/42] hysdn: convert to net_device_ops and other
 updates
Date: Wed, 07 Jan 2009 18:03:50 -0800 (PST)
Message-ID: <20090107.180350.156876921.davem@davemloft.net>
References: <20090107003316.784424362@vyatta.com>
	<20090107003348.948135773@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757408AbZAHCDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 21:03:48 -0500
In-Reply-To: <20090107003348.948135773@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 06 Jan 2009 16:33:48 -0800

> Several API problems fixed:
>   * use proper allocation
>   * handle renames
>   * convert to net_device_ops
>   * use internal net_device_stats
> 
> This driver is putrid (as in old and rotten), so I doubt any one uses it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
