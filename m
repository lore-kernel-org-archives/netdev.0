From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: export device speed and duplex via sysfs
Date: Mon, 05 Oct 2009 00:44:21 -0700 (PDT)
Message-ID: <20091005.004421.23261516.davem@davemloft.net>
References: <20091002180742.GH4436@gospo.rdu.redhat.com>
	<1254507554.8795.12.camel@achroite>
	<20091002200141.GB1639@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758497AbZJEHo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:44:26 -0400
In-Reply-To: <20091002200141.GB1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Fri, 2 Oct 2009 16:01:41 -0400

> I took a look at /sys/class/net/ethX/ and felt like the information was
> pretty complete with the exception of the link speed and duplex, so I
> thought it would be a good place to add it.  I personally wouldn't mind
> having most of the information presented in ethtool available via sysfs,
> but I figured I would walk before running.

I have no objections to this, I applied v2 of your patch to
net-next-2.6, thanks!
