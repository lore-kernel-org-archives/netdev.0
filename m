From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Device statistics type fixes
Date: Sat, 12 Jun 2010 18:19:00 -0700 (PDT)
Message-ID: <20100612.181900.184827506.davem@davemloft.net>
References: <1276021249.2185.55.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751349Ab0FMBSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jun 2010 21:18:49 -0400
In-Reply-To: <1276021249.2185.55.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 08 Jun 2010 19:20:49 +0100

> While messing about with net_device_stats types, I spotted a couple of
> drivers printing device statistics using the format %ld.

Both applied to net-next-2.6, thanks Ben.
