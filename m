From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax: fix i2400m printk formats
Date: Wed, 11 Mar 2009 23:24:17 -0700 (PDT)
Message-ID: <20090311.232417.215239560.davem@davemloft.net>
References: <1236710909-27528-1-git-send-email-inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org,
	randy.dunlap@oracle.com
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39775
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754499AbZCLGYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 02:24:32 -0400
In-Reply-To: <1236710909-27528-1-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Tue, 10 Mar 2009 11:48:29 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix printk format warnings:
> 
> drivers/net/wimax/i2400m/netdev.c:523: warning: format '%zu' expects type 'size_t', but argument 7 has type 'unsigned int'
> drivers/net/wimax/i2400m/netdev.c:548: warning: format '%zu' expects type 'size_t', but argument 7 has type 'unsigned int'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

Applied.
