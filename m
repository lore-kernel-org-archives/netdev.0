From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25][NETNS]: Fix race between put_net() and
 netlink_kernel_create().
Date: Thu, 31 Jan 2008 03:45:02 -0800 (PST)
Message-ID: <20080131.034502.79006965.davem@davemloft.net>
References: <47988F61.9070505@openvz.org>
	<20080130.193128.136832319.davem@davemloft.net>
	<47A1AB95.4080202@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751743AbYAaLom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 06:44:42 -0500
In-Reply-To: <47A1AB95.4080202@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 31 Jan 2008 14:05:57 +0300

> I have one more patch pending in netdev@ and some more to be sent
> (cleanups, small fixes and net namespaces). Do I have to wait till
> net-2.6.26, or can I start (re-)sending them while 2.6.25 merge
> window is open?

Send it, I'll take a look at it.
