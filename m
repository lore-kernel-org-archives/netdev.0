From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: Allow setting mac address while device is up
Date: Sat, 10 Nov 2007 21:52:53 -0800 (PST)
Message-ID: <20071110.215253.108588822.davem@davemloft.net>
References: <47334553.6000206@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751315AbXKKFwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:52:54 -0500
In-Reply-To: <47334553.6000206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 08 Nov 2007 18:20:19 +0100

> This patch allows to change a VLAN device's MAC address while
> the device is up. Doesn't seem worth to hold back until
> 2.6.25-rc since it can't break anything without actually
> getting used (and it does work :))

Agreed, and applied, thanks Patrick!

 
