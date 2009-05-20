From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: route templates missing protocol value
Date: Wed, 20 May 2009 12:42:06 -0700 (PDT)
Message-ID: <20090520.124206.104359882.davem@davemloft.net>
References: <4A0EA766.9090008@6wind.com>
	<4A11B52D.8030105@6wind.com>
	<20090520123038.5bb2a2da@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, jean-mickael.guerin@6wind.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39327
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752759AbZETTmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 15:42:07 -0400
In-Reply-To: <20090520123038.5bb2a2da@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 20 May 2009 12:30:38 -0700

> The IPV6 routing templates are missing the protocol value so
> when they are used, the routes have the protocol RTPROT_UNSPEC (0).
> This confuses Zebra routing protocol daemon that makes kernel routes
> a special case. This was first noticed by Jean-Mickael Guerin
> who wrote this patch.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

What's wrong with Jean-Mickael Guerin's patch?  He provided
a signoff and everything.

Are you Napoleon? :-)


