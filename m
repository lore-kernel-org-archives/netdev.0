From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/3][ROUTE] Convert rt_hash_lock_init()
 macro into function
Date: Wed, 05 Dec 2007 21:15:13 -0800 (PST)
Message-ID: <20071205.211513.147642225.davem@davemloft.net>
References: <4756DB47.7050403@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45943
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751383AbXLFFPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:15:13 -0500
In-Reply-To: <4756DB47.7050403@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 05 Dec 2007 20:09:27 +0300

> There's no need in having this function exist in a form
> of macro. Properly formatted function looks much better.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied, thanks.
