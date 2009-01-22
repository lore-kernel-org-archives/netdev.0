From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pppoe - get rid of DECLARE_MAC_BUF
Date: Thu, 22 Jan 2009 13:52:50 -0800 (PST)
Message-ID: <20090122.135250.209081273.davem@davemloft.net>
References: <20090122172508.GC20140@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752768AbZAVVws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 16:52:48 -0500
In-Reply-To: <20090122172508.GC20140@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Thu, 22 Jan 2009 20:25:08 +0300

> While was playing with PPP namespaces I occasionally brought
> back DECLARE_MAC_BUF which is not needed (we have %pM here).
> Fix it.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Applied, thanks.
