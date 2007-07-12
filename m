From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK 04/04]: rtnl_link: allow specifying initial device
 address
Date: Wed, 11 Jul 2007 19:43:00 -0700 (PDT)
Message-ID: <20070711.194300.05159762.davem@davemloft.net>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
	<20070711173818.18369.51589.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com, xemul@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933170AbXGLCmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:42:38 -0400
In-Reply-To: <20070711173818.18369.51589.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 11 Jul 2007 19:38:19 +0200 (MEST)

> [RTNETLINK]: rtnl_link: allow specifying initial device address
> 
> Drivers need to validate the initial addresses in their netlink attribute
> validation function or manually reject them if they can't support this.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.

Thanks Patrick.
