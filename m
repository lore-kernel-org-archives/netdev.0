From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb3: set phy's mdio dev before the phy init
 sequence
Date: Wed, 20 May 2009 20:52:21 -0700 (PDT)
Message-ID: <20090520.205221.36274904.davem@davemloft.net>
References: <20090521015602.1905.98758.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45583
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754480AbZEUDwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 23:52:22 -0400
In-Reply-To: <20090521015602.1905.98758.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 20 May 2009 18:56:02 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> mdio's dev field needs to be set before mdio ops occur.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
