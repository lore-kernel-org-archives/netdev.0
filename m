From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add ARP notify option for devices
Date: Sun, 01 Feb 2009 01:04:55 -0800 (PST)
Message-ID: <20090201.010455.124561041.davem@davemloft.net>
References: <4981FA36.2000301@goop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xensource.com
To: jeremy@goop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35213
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751673AbZBAJE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:04:58 -0500
In-Reply-To: <4981FA36.2000301@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 29 Jan 2009 10:49:26 -0800

> This adds another inet device option to enable gratuitous ARP
> when device is brought up or address change. This is handy for
> clusters or virtualization.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

I'm fine with this, applied, thanks.
