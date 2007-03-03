From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] bonding: only receive ARPs for us
Date: Fri, 02 Mar 2007 20:26:08 -0500
Message-ID: <45E8CEB0.3070204@garzik.org>
References: <200703010103.l2113R22030799@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55664 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992872AbXCCB0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:26:12 -0500
In-Reply-To: <200703010103.l2113R22030799@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	The ARP validation code only needs ARPs for the bonding device.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

I seem to have lost the context of this.  Did this get discussed, and 
need further revision?

The three patches from 2/28/2007 look OK to me, and I just wanted to 
make sure before applying them.

	Jeff



