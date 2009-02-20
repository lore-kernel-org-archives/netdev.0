From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ISDN: fix sc/shmem printk format warning
Date: Fri, 20 Feb 2009 00:54:52 -0800 (PST)
Message-ID: <20090220.005452.213401495.davem@davemloft.net>
References: <20090219134740.4dff14c2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de, akpm@linux-foundation.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34916
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752561AbZBTIzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:55:11 -0500
In-Reply-To: <20090219134740.4dff14c2.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 19 Feb 2009 13:47:40 -0800

> Fix isdn/sc/shmem.c printk format warning:
> 
> drivers/isdn/sc/shmem.c:57: warning: format '%d' expects type 'int', but argument 3 has type 'size_t'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
