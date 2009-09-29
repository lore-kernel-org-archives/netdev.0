From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Pv-drivers] [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC driver: vmxnet3
Date: Tue, 29 Sep 2009 23:23:20 +0200
Message-ID: <200909292323.20713.arnd@arndb.de>
References: <20090929085333.GC3958@sequoia.sous-sol.org> <8B1F619C9F5F454E81D90D3C161698D7017DB76582@EXCH-MBX-3.vmware.com> <20090929.125530.31894576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bhavesh@vmware.com, chrisw@sous-sol.org, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, greg@kroah.com,
	anthony@codemonkey.ws, jgarzik@pobox.com,
	akpm@linux-foundation.org, shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61853 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbZI3MtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 08:49:15 -0400
In-Reply-To: <20090929.125530.31894576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 September 2009, David Miller wrote:
> > 
> > These header files are indeed shared with the host implementation,
> > as you've guessed. If it's not a big deal, we would like to keep
> > the names the same, just for our own sanity's sake?
> 
> No.  This isn't your source tree, it's everyone's.  So you should
> adhere to basic naming conventions and coding standards of the
> tree regardless of what you happen to use or need to use internally.

Well, there is nothing wrong with making the identifiers the same
everywhere, as long as they all follow the Linux coding style ;-).

I heard that a number of cross-OS device drivers do that nowadays.

	Arnd <><
