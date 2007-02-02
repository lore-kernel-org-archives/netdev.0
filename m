From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20-rc7 1/2] atl1: get rid of pci_module_init
Date: Fri, 02 Feb 2007 08:28:29 -0500
Message-ID: <45C33C7D.4000203@garzik.org>
References: <20070201011052.GA1752@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	alan@lxorguk.ukuu.org.uk
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48313 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161131AbXBBN2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 08:28:34 -0500
In-Reply-To: <20070201011052.GA1752@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> From: Jay Cliburn <jacliburn@bellsouth.net>
> 
> pci_module_init is deprecated.  Use pci_register_driver instead.
> Discovered by and modification suggested by Alan Cox.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

applied 1-2 to #atl1


