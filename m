From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] linux/net.h: fix kernel-doc warnings
Date: Fri, 02 Jul 2010 21:59:42 -0700 (PDT)
Message-ID: <20100702.215942.71114758.davem@davemloft.net>
References: <20100701161858.a24a5803.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751274Ab0GCE73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 00:59:29 -0400
In-Reply-To: <20100701161858.a24a5803.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 1 Jul 2010 16:18:58 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix kernel-doc warnings in linux/net.h:
> 
> Warning(include/linux/net.h:151): No description found for parameter 'wq'
> Warning(include/linux/net.h:151): Excess struct/union/enum/typedef member 'fasync_list' description in 'socket'
> Warning(include/linux/net.h:151): Excess struct/union/enum/typedef member 'wait' description in 'socket'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied.
