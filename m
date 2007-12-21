From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9][BNX2]: Enable new tx ring.
Date: Thu, 20 Dec 2007 20:01:51 -0800 (PST)
Message-ID: <20071220.200151.80640211.davem@davemloft.net>
References: <1198182815.9163.34.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754119AbXLUEBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:01:51 -0500
In-Reply-To: <1198182815.9163.34.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 20 Dec 2007 12:33:35 -0800

> [BNX2]: Enable new tx ring.
> 
> Enable new tx ring and add new MSIX handler and NAPI poll function
> for the new tx ring.  Enable MSIX when the hardware supports it.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
