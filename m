From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 68/77] prism54: convert to internal net_device_stats
Date: Sat, 21 Mar 2009 22:53:54 -0700 (PDT)
Message-ID: <20090321.225354.13734304.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053717.765575826@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcgrof@gmail.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43771
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753971AbZCVFyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 01:54:07 -0400
In-Reply-To: <20090321053717.765575826@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:36:35 -0700

> Also, make ethtool_ops const as it should be, and get rid
> of useless cast.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
