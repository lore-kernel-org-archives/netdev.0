From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] korina: fix printk formatting, add final info line
Date: Thu, 13 Aug 2009 16:27:38 -0700 (PDT)
Message-ID: <20090813.162738.18086398.davem@davemloft.net>
References: <20090812221509.725F74CEAA@orbit.nwl.cc>
	<20090812222249.39EAB4CEAA@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	florian@openwrt.org, roel.kluin@gmail.com
To: n0-1@freewrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56552
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756468AbZHMX11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:27:27 -0400
In-Reply-To: <20090812222249.39EAB4CEAA@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <n0-1@freewrt.org>
Date: Thu, 13 Aug 2009 00:22:46 +0200

> The macro DRV_NAME contains "korina", the field dev->name points to the
> actual interface name. So messages were formerly prefixed with
> 'korinaeth2:' (on my system).
> 
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Applied to net-next-2.6
