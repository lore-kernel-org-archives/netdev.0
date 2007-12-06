From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove prototype of ip_rt_advice
Date: Thu, 06 Dec 2007 02:19:34 -0800 (PST)
Message-ID: <20071206.021934.181288092.davem@davemloft.net>
References: <20071206101743.GA10673@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45184
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752384AbXLFKTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 05:19:38 -0500
In-Reply-To: <20071206101743.GA10673@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 6 Dec 2007 13:17:43 +0300

> ip_rt_advice has been gone, so no need to keep prototype and debug message.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied to net-2.6, thanks.
