From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC driver:
 vmxnet3
Date: Mon, 28 Sep 2009 17:22:07 -0700
Message-ID: <20090929002207.GB31372@kroah.com>
References: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Chris Wright <chrisw@sous-sol.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:42015 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753558AbZI2AWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2009 20:22:39 -0400
Content-Disposition: inline
In-Reply-To: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2009 at 04:56:45PM -0700, Shreyas Bhatewara wrote:
> 
> Please consider this for inclusion in the linux net tree. I will be
> glad to receive your review comments and answer queries in order to be
> accepted in mainline in 2.6.32 release cycle.

It's usually a bit late given that the big merge window for 2.6.32 is
now closed.

> The patch applies to 2.6.31-rc9.

2.6.32-rc1 is out, you should rebase to it as a few tens of thousands of
changes have already happened since 2.6.31-rc9 :)

thanks,

greg k-h
