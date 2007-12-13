From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [IPV6] Always pass a valid nl_info to
 inet6_rt_notify.
Date: Thu, 13 Dec 2007 09:45:35 -0800 (PST)
Message-ID: <20071213.094535.04530080.davem@davemloft.net>
References: <20071213135854.GA9691@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754817AbXLMRpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:45:35 -0500
In-Reply-To: <20071213135854.GA9691@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 13 Dec 2007 16:58:54 +0300

> [IPV6] Always pass a valid nl_info to inet6_rt_notify.
> 
> This makes the code in the inet6_rt_notify more straightforward and provides
> groud for namespace passing.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks!
