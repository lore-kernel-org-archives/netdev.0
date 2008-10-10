From: David Miller <davem@davemloft.net>
Subject: Re: gre: minor cleanups in netlink interface
Date: Fri, 10 Oct 2008 12:11:28 -0700 (PDT)
Message-ID: <20081010.121128.240824683.davem@davemloft.net>
References: <48EF7D24.6040400@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert.xu@redhat.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760754AbYJJTLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 15:11:52 -0400
In-Reply-To: <48EF7D24.6040400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 10 Oct 2008 18:04:52 +0200

>     gre: minor cleanups in netlink interface
>     
>     - use typeful helpers for IFLA_GRE_LOCAL/IFLA_GRE_REMOTE
>     - replace magic value by FIELD_SIZEOF
>     - use MODULE_ALIAS_RTNL_LINK macro
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
