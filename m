From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] Cleanup IN_DEV_MFORWARD macro
Date: Tue, 11 Dec 2007 02:17:05 -0800 (PST)
Message-ID: <20071211.021705.49327297.davem@davemloft.net>
References: <4759729A.4030403@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org,
	herbert@gondor.apana.org.au
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51038
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751803AbXLKKRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:17:05 -0500
In-Reply-To: <4759729A.4030403@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 19:19:38 +0300

> This is essentially IN_DEV_ANDCONF with proper arguments.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
