From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] via-velocity: Enable support for adaptive
 interrupt supression
Date: Fri, 20 Nov 2009 09:47:00 -0800 (PST)
Message-ID: <20091120.094700.134282710.davem@davemloft.net>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091120161217.45e611a6@marrow.netinsight.se>
	<20091120090505.0fa700e6@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.kagstrom@netinsight.net, netdev@vger.kernel.org,
	davej@redhat.com, romieu@fr.zoreil.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752775AbZKTRqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:46:43 -0500
In-Reply-To: <20091120090505.0fa700e6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Nov 2009 09:05:05 -0800

> This should be done via ethtool irq coalescing settings not more module paramets.

Agreed.
