From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] sfc: Clean up properly on reset failure paths
Date: Wed, 04 Mar 2009 17:55:27 -0800 (PST)
Message-ID: <20090304.175527.248212229.davem@davemloft.net>
References: <1236196272.3140.15.camel@achroite>
	<1236196372.3140.19.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37445
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751427AbZCEBzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 20:55:42 -0500
In-Reply-To: <1236196372.3140.19.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 04 Mar 2009 19:52:52 +0000

> If MAC switching fails, stop the port properly.
> 
> If PHY reinitialisation fails, clear the port_initialized flag.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
