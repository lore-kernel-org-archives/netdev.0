From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Wed, 18 Nov 2009 09:57:16 -0800 (PST)
Message-ID: <20091118.095716.61189059.davem@davemloft.net>
References: <20091118154313.GE325@e-circ.dyndns.org>
	<20091118.080849.196755366.davem@davemloft.net>
	<20091118164126.GF325@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: kurt.van.dijck@eia.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757836AbZKRR47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 12:56:59 -0500
In-Reply-To: <20091118164126.GF325@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Date: Wed, 18 Nov 2009 17:41:26 +0100

> This patch allows adding sysfs attribute groups during netdevice registration.
> The idea is that before the register_netdev call, several calls to
> netdev_sysfs_add_group can be done. These attributes are accessible (by
> udev) during the uevent.
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Patch is corrupted by your email client.  Tab characters have
been turned into spaces, etc.

Please fix this up and resubmit.

Thanks.
