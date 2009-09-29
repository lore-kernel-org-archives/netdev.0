From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC driver:
 vmxnet3
Date: Mon, 28 Sep 2009 17:20:56 -0700
Message-ID: <20090929002056.GA31372@kroah.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753844AbZI2AWm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 28, 2009 at 04:56:45PM -0700, Shreyas Bhatewara wrote:
> Ethernet NIC driver for VMware's vmxnet3
> 
> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> 
> This patch adds driver support for VMware's virtual Ethernet NIC : vmxnet3
> Guests running on VMware hypervisors supporting vmxnet3 device will thus
> have access to improved network functionalities and performance.
> 
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

I thought this was going to be submitted for the drivers/staging/ tree.
What happened?

thanks,

greg k-h
