From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] xen-netback: double free on unload
Date: Mon, 24 Jun 2013 11:57:52 +0300
Message-ID: <20130624085752.GF5714@mwanda>
References: <20130621062008.GA10873@elgon.mountain>
 <20130624.002607.1816906327683052502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ian.campbell@citrix.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23035 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251Ab3FXI6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 04:58:10 -0400
Content-Disposition: inline
In-Reply-To: <20130624.002607.1816906327683052502.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry.  For some reason I got confused and thought this bug was
older.  I'll update my QC scripts to test for this.

regards,
dan carpenter
