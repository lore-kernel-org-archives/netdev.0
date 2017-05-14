From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Sun, 14 May 2017 11:51:16 -0400 (EDT)
Message-ID: <20170514.115116.499149210596634881.davem@davemloft.net>
References: <20170510072627.12060-1-hch@lst.de>
        <1494514662.2489.1.camel@sandisk.com>
        <20170514055848.GA23149@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Bart.VanAssche@sandisk.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, stable@vger.kernel.org,
        ubraun@linux.vnet.ibm.com
To: hch@lst.de
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170514055848.GA23149@lst.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sun, 14 May 2017 07:58:48 +0200

> this patch has not been superceeded by anything, can you explain why
> it has been marked as such in patchworks?

I think you're being overbearing by requiring this to be marked BROKEN
and I would like you to explore other ways with the authors to fix
whatever perceived problems you think SMC has.

You claim that this is somehow "urgent" is false.  You can ask
distributions to disable SMC or whatever in the short term if it
reallly, truly, bothers you.
