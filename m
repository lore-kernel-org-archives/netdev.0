From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] sfc: Fix reporting of PHY id
Date: Mon, 02 Mar 2009 03:26:33 -0800 (PST)
Message-ID: <20090302.032633.150948810.davem@davemloft.net>
References: <1235775847.3164.6.camel@achroite>
	<1235776035.3164.22.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37982
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752203AbZCBL0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:26:51 -0500
In-Reply-To: <1235776035.3164.22.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 27 Feb 2009 23:07:15 +0000

> Shuffle bits of the OUI into the conventional written order.
> 
> Replace PHY id component macros with functions.
> 
> Zero-pad PHY id components in log messages.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
