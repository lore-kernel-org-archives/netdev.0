From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] e1000e: normalize usage of serdes_has_link
Date: Thu, 05 Feb 2009 23:55:52 -0800 (PST)
Message-ID: <20090205.235552.160237986.davem@davemloft.net>
References: <20090204220434.GD20091@ldl.fc.hp.com>
	<A78C6259B11833419567082E2DC0C256C0E7D216@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: achiang@hp.com, jeff@garzik.org, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752889AbZBFHzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 02:55:55 -0500
In-Reply-To: <A78C6259B11833419567082E2DC0C256C0E7D216@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Date: Wed, 4 Feb 2009 17:23:18 -0800

> >-----Original Message-----
> >From: Alex Chiang [mailto:achiang@hp.com]
> >Sent: Wednesday, February 04, 2009 2:05 PM
> >To: davem@davemloft.net
> >Cc: Kirsher, Jeffrey T; jeff@garzik.org; Brandeburg, Jesse; Allan, Bruce W;
> >netdev@vger.kernel.org
> >Subject: [net-next PATCH] e1000e: normalize usage of serdes_has_link
> >
> >Cosmetic change to use struct e1000_mac_info.serdes_has_link
> >consistently as the 'bool' that it's declared as.
> >
> >No functional change.
> >
> >Signed-off-by: Alex Chiang <achiang@hp.com>
> 
> Acked-by: Jeff Kirsher <Jeffrey.t.kirsher@intel.com>

Applied, thanks.
