From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] fec: add FEC platform support to ColdFire CPU's
 setup code
Date: Thu, 26 Feb 2009 22:40:52 -0800 (PST)
Message-ID: <20090226.224052.186466825.davem@davemloft.net>
References: <200902170053.n1H0r15O002064@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, gerg@uclinux.org, netdev@vger.kernel.org
To: gerg@snapgear.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752883AbZB0GlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 01:41:08 -0500
In-Reply-To: <200902170053.n1H0r15O002064@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@snapgear.com>
Date: Tue, 17 Feb 2009 10:53:01 +1000

> m68knommu: add FEC platform support to ColdFire CPU's setup code
> 
> Move the per-CPU FEC driver setup code into the actual platform
> setup code for each ColdFire CPU varient.
> 
> Signed-off-by: Greg Ungerer <gerg@uclinux.org>

Applied to net-next-2.6, with trailing whitespace errors fixed
up.
