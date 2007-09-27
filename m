From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fixed broken bootp compilation
Date: Thu, 27 Sep 2007 11:58:36 -0700 (PDT)
Message-ID: <20070927.115836.103001176.davem@davemloft.net>
References: <20070927104622.GA8349@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754693AbXI0S6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 14:58:38 -0400
In-Reply-To: <20070927104622.GA8349@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 27 Sep 2007 14:46:22 +0400

> Compilation fix. Extra bracket removed.
> Broken by "[NET]: Wrap netdevice hardware header creation" from
> Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks Denis.
