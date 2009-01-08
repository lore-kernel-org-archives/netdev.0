From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 37/42] synclink: convert devices to new API (rev2)
Date: Wed, 07 Jan 2009 18:08:02 -0800 (PST)
Message-ID: <20090107.180802.118061961.davem@davemloft.net>
References: <20090107003316.784424362@vyatta.com>
	<20090107003349.468715485@vyatta.com>
	<20090107154835.37f4de4c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752595AbZAHCIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 21:08:01 -0500
In-Reply-To: <20090107154835.37f4de4c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 7 Jan 2009 15:48:35 -0800

> Convert to net_device_ops and internal net_device_stats.
> Remove unneeded last_rx update.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I'm deferring this while you and Krzysztof work out how
to implement this properly.
