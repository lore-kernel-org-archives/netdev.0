From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: leave PCI config space writeable
Date: Mon, 14 Dec 2009 22:07:30 -0800 (PST)
Message-ID: <20091214.220730.155444785.davem@davemloft.net>
References: <20091214103458.7787e011@nehalam>
	<200912142249.07753.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43353
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752664AbZLOGH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 01:07:28 -0500
In-Reply-To: <200912142249.07753.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Mon, 14 Dec 2009 22:49:07 +0100

> On Monday 14 December 2009, Stephen Hemminger wrote:
>> Since power management is done by PCI subsystem as well as driver,
>> don't toggle the bit that disables PCI register writes.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied.
