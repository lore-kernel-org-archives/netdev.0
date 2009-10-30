From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Fri, 30 Oct 2009 12:28:19 -0700 (PDT)
Message-ID: <20091030.122819.190362506.davem@davemloft.net>
References: <20091029235807.GF3228@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: bphilips@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52363
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932204AbZJ3T1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 15:27:55 -0400
In-Reply-To: <20091029235807.GF3228@jenkins.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brandon Philips <bphilips@suse.de>
Date: Thu, 29 Oct 2009 16:58:07 -0700

> Before bringing up a sky2 interface up ethtool reports 
> "Link detected: yes". Do as ixgbe does and netif_carrier_off() on
> probe().
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>

Applied to net-2.6, thanks.
