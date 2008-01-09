From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/6][DECNET] Switch to using ctl_paths.
Date: Wed, 09 Jan 2008 00:31:58 -0800 (PST)
Message-ID: <20080109.003158.90639997.davem@davemloft.net>
References: <47839C30.2040402@openvz.org>
	<47839E88.2040604@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751059AbYAIIb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:31:59 -0500
In-Reply-To: <47839E88.2040604@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Jan 2008 19:02:16 +0300

> The decnet includes two places to patch. The first one is 
> the net/decnet table itself, and it is patched just like 
> other subsystems in the first patch in this series.
> 
> The second place is a bit more complex - it is the 
> net/decnet/conf/xxx entries,. similar to those in 
> ipv4/devinet.c and ipv6/addrconf.c. This code is made similar 
> to those in ipv[46].
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
