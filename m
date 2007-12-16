From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 6/7] Switch users of ipv4_devconf_dflt to
 use the pernet one
Date: Sun, 16 Dec 2007 13:32:23 -0800 (PST)
Message-ID: <20071216.133223.157279452.davem@davemloft.net>
References: <475ECC69.1040809@openvz.org>
	<475ED01E.5020505@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48843
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757004AbXLPVcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:32:33 -0500
In-Reply-To: <475ED01E.5020505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 11 Dec 2007 20:59:58 +0300

> They are all collected in the net/ipv4/devinet.c file and
> mostly use the IPV4_DEVCONF_DFLT macro.
> 
> So I add the net parameter to it and patch users accordingly.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
