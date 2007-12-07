From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] multiple namespaces in the all dst_ifdown
 routines
Date: Fri, 07 Dec 2007 00:39:14 -0800 (PST)
Message-ID: <20071207.003914.143266434.davem@davemloft.net>
References: <20071206121746.GA17899@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57448
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750952AbXLGIjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:39:17 -0500
In-Reply-To: <20071206121746.GA17899@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 6 Dec 2007 15:17:46 +0300

> move dst entries to a namespace loopback to catch refcounting leaks.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
