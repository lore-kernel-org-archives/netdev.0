From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fec: remove ColdFire specific setup code from FEC
 driver
Date: Thu, 26 Feb 2009 22:43:00 -0800 (PST)
Message-ID: <20090226.224300.177190267.davem@davemloft.net>
References: <200902170053.n1H0r1Zn002066@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, gerg@uclinux.org, netdev@vger.kernel.org
To: gerg@snapgear.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751236AbZB0GnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 01:43:16 -0500
In-Reply-To: <200902170053.n1H0r1Zn002066@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@snapgear.com>
Date: Tue, 17 Feb 2009 10:53:01 +1000

> m68knommu: remove ColdFire specific setup code from FEC driver
> 
> Remove the ColdFire CPU specific setup from here. The ColdFire
> CPU platform code now sets up all this.
> 
> Signed-off-by: Greg Ungerer <gerg@uclinux.org>

Also applied.
