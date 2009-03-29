From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff.h: fix missing kernel-doc
Date: Sat, 28 Mar 2009 23:38:47 -0700 (PDT)
Message-ID: <20090328.233847.205232336.davem@davemloft.net>
References: <20090328215227.246b8a88.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751966AbZC2Gi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 02:38:59 -0400
In-Reply-To: <20090328215227.246b8a88.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Sat, 28 Mar 2009 21:52:27 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Add missing struct field to fix kernel-doc warning:
> 
> Warning(include/linux/skbuff.h:182): No description found for parameter 'flags'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks!
