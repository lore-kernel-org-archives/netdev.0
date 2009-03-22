From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 77/77] netdev: expose net_device_ops compat as config
 option
Date: Sat, 21 Mar 2009 22:57:28 -0700 (PDT)
Message-ID: <20090321.225728.254652404.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053718.453648503@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753712AbZCVF5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 01:57:41 -0400
In-Reply-To: <20090321053718.453648503@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:36:44 -0700

> Now that most network device drivers in (all but one in x86_64 allmodconfig)
> support net_device_ops. Expose it as a configuration parameter. Still
> need to address even older 32 bit drivers, and other arch before
> compatiablity can be scheduled for removal in some future release.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
