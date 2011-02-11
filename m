From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix ifenslave build flags
Date: Thu, 10 Feb 2011 20:04:51 -0800 (PST)
Message-ID: <20110210.200451.71107138.davem@davemloft.net>
References: <4D54826D.3060406@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexey.salmin@gmail.com
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48141
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910Ab1BKEEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 23:04:15 -0500
In-Reply-To: <4D54826D.3060406@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 10 Feb 2011 16:27:25 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> -I (include path) should be specified for host builds.
> This one was overlooked somehow.  Fixes
> https://bugzilla.kernel.org/show_bug.cgi?id=25902
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Reported-by: Alexey Salmin <alexey.salmin@gmail.com>

I'll apply this, thanks Randy.
