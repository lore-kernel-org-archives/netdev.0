From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 32/77] usbnet: convert rndis driver to use dev_get_stats
Date: Sat, 21 Mar 2009 20:01:09 -0700 (PDT)
Message-ID: <20090321.200109.91593579.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053714.963078292@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753108AbZCVDBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 23:01:22 -0400
In-Reply-To: <20090321053714.963078292@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:35:59 -0700

> dev_get_stats() handles all issues with net_device_ops
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
