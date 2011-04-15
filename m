From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ethtool: remove phys_id from ethtool_ops
Date: Thu, 14 Apr 2011 23:46:54 -0700 (PDT)
Message-ID: <20110414.234654.71103337.davem@davemloft.net>
References: <20110408170830.3ab079e8@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37658
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752774Ab1DOGra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 02:47:30 -0400
In-Reply-To: <20110408170830.3ab079e8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 8 Apr 2011 17:08:30 -0700

> Hold this patch until after the Intel and Qlogic driver
> changes are merged into net-next. Patches have been submitted
> but still waiting for vendor.
> 
> After that all the upstream kernel drivers now use phys_id, 
> and the old ethtool_ops interface (phys_id) can be removed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Since everything is now merged, I've applied this.

Thanks!
