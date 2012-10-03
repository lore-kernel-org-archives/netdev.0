From: "Nicholas A. Bellinger" <nab@risingtidesystems.com>
Subject: Re: [PATCH 0/2] PCI-Express Non-Transparent Bridge Support
Date: Wed, 03 Oct 2012 00:11:29 -0700
Message-ID: <1349248289.28145.165.camel@haakon2.linux-iscsi.org>
References: <1349213177-9985-1-git-send-email-jon.mason@intel.com>
Reply-To: nab@risingtidesystems.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Christoph Hellwig <hch@lst.de>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1349213177-9985-1-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-10-02 at 14:26 -0700, Jon Mason wrote:
> I am submitting version 4 of the PCI-Express Non-Transparent Bridge
> patches for inclusion in 3.7.  All outstanding issues from the RFC
> process have been addressed.
> 
> version 1
> http://thread.gmane.org/gmane.linux.kernel.pci/16443
> 
> Version 2 incorporates numerous clean-ups 
> http://thread.gmane.org/gmane.linux.kernel.pci/16696
> 
> Version 3 incorporates changes to conform NTB and client devices to the
> Linux device model (per Greg KH's request).
> http://thread.gmane.org/gmane.linux.kernel.pci/17808
> 
> Version 4 removes the transport transmit tasklet (per Dave Miller's
> request).
> http://thread.gmane.org/gmane.linux.network/244491
> 

Hi Jon,

I'm really excited to see this series merged for v3.7-rc code.

Please feel free to add my:

Reviewed-by: Nicholas Bellinger <nab@linux-iscsi.org>

to the two individual patches for an initial merge.  I'm not sure which
tree that your intending to take this code upstream via, but also feel
free to add my:

Acked-by: Nicholas Bellinger <nab@linux-iscsi.org>

of your maintainer-ship of /drivers/ntb/ subsystem code.

Very nice work on this series Jon !

--nab
