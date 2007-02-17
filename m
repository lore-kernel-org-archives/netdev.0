From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] atl1: drop NET_PCI from Kconfig
Date: Sat, 17 Feb 2007 15:18:18 -0500
Message-ID: <45D7630A.4040502@garzik.org>
References: <20070215021213.GB9753@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	crsprouse@gmail.com
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47644 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020AbXBQUSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:18:23 -0500
In-Reply-To: <20070215021213.GB9753@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> From: Jay Cliburn <jacliburn@bellsouth.net>
> 
> The atl1 driver doesn't need NET_PCI.  Remove it from Kconfig.
> Noticed by Chad Sprouse.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> Signed-off-by: Chris Snook <csnook@redhat.com>

applied 1-6


