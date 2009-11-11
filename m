From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] decnet: use RCU to find network devices
Date: Tue, 10 Nov 2009 22:49:48 -0800 (PST)
Message-ID: <20091110.224948.15168196.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.615305929@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christine.caulfield@googlemail.com, hannes@hanneseder.net,
	adobriyan@gmail.com, swhiteho@redhat.com, netdev@vger.kernel.org,
	linux-decnet-users@lists.sourceforge.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40928
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753275AbZKKGtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:49:22 -0500
In-Reply-To: <20091110175647.615305929@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 10 Nov 2009 09:54:53 -0800

> When showing device statistics use RCU rather than read_lock(&dev_base_lock)
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
