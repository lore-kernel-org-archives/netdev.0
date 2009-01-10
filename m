From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdev: add missing set_mac_address hook (rev2)
Date: Fri, 09 Jan 2009 23:11:20 -0800 (PST)
Message-ID: <20090109.231120.268060427.davem@davemloft.net>
References: <20090109124427.71d15306@s6510>
	<20090109131314.312d514a@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754152AbZAJHLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:11:19 -0500
In-Reply-To: <20090109131314.312d514a@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 9 Jan 2009 13:13:14 -0800

> Subject: netdev: add missing set_mac_address hook
> 
> Many drivers lost the ability to set ethernet address accidently
> during the net_device_ops conversion.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
