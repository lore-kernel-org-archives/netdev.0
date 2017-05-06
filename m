From: "hch@lst.de" <hch@lst.de>
Subject: Re: net/smc and the RDMA core
Date: Sat, 6 May 2017 10:25:39 +0200
Message-ID: <20170506082539.GA3987@lst.de>
References: <20170501163311.GA22209@lst.de> <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com> <1493750358.2552.13.camel@sandisk.com> <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me> <20170504084825.GA5399@lst.de> <efa9bd6d-1df9-952a-7f32-c2ee6bffcae5@linux.vnet.ibm.com> <20170504153155.GB854@obsidianresearch.com> <750b09b5-f898-fe7f-1e82-1f6c06cc0f58@linux.vnet.ibm.com> <20170505171017.GA29554@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ursula Braun <ubraun@linux.vnet.ibm.com>,
        "hch@lst.de" <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:59115 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750907AbdEFIZk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 6 May 2017 04:25:40 -0400
Content-Disposition: inline
In-Reply-To: <20170505171017.GA29554@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 05, 2017 at 11:10:17AM -0600, Jason Gunthorpe wrote:
> I recommend immediately sending a kconfig patch cc'd to stable making
> SMC require CONFIG_BROKEN so that nobody inadvertantly turns it on.

Yes, I'll send the patch.
