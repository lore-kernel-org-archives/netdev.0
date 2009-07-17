From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: revert shutdown changes
Date: Thu, 16 Jul 2009 18:10:42 -0700 (PDT)
Message-ID: <20090716.181042.261706731.davem@davemloft.net>
References: <20090716162057.20cd3ef1@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43298
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933901AbZGQBKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:10:37 -0400
In-Reply-To: <20090716162057.20cd3ef1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 16 Jul 2009 16:20:57 -0700

> The commit changes to shutdown path broke startup on some systems.
> 
> revert commit c0bad0f2e4366d5bbfe0c4a7a80bca8f4b05272b
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
