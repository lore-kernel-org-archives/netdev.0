From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 02 Mar 2011 16:50:09 -0800 (PST)
Message-ID: <20110302.165009.200353108.davem@davemloft.net>
References: <20110302164114.2e110ea0@nehalam>
	<20110302.164333.116393112.davem@davemloft.net>
	<20110302164637.6651b34f@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752608Ab1CCAtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 19:49:32 -0500
In-Reply-To: <20110302164637.6651b34f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Mar 2011 16:46:37 -0800

> The addresses (that matter) when VPN is up are:

I really need to know what addresses interfaces have the time of the
__ip_dev_find() call which, if I'm not mistaken, is before the VPN is
up.
