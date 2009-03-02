From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] sfc: Clean up LED control
Date: Mon, 02 Mar 2009 03:26:49 -0800 (PST)
Message-ID: <20090302.032649.212864193.davem@davemloft.net>
References: <1235775847.3164.6.camel@achroite>
	<1235776083.3164.28.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37991
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754839AbZCBL1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:27:07 -0500
In-Reply-To: <1235776083.3164.28.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 27 Feb 2009 23:08:03 +0000

> Reinitialise LEDs after overriding them for identification.
> 
> Rename set_fault_led method to set_id_led since we always use it for
> NIC identification and not faults.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
