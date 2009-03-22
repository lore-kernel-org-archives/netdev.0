From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 72/77] ipw2x00: convert infrastructure for use by
 net_device_ops
Date: Sat, 21 Mar 2009 22:56:54 -0700 (PDT)
Message-ID: <20090321.225654.150752910.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053718.065171867@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jkosina@suse.cz, dstreba@suse.cz, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39604
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752961AbZCVF5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 01:57:07 -0400
In-Reply-To: <20090321053718.065171867@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:36:39 -0700

> Expose routines so drivers can hook. Only set ptrs in netdev
> if using old compat code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
