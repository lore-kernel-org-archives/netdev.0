From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 net-next] qed*: Utilize Firmware 8.15.3.0
Date: Mon, 13 Mar 2017 16:19:47 -0700
Message-ID: <20170313231947.GA31265@infradead.org>
References: <1489250358-28955-1-git-send-email-Yuval.Mintz@cavium.com>
 <20170313.153347.308062967844295379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval.Mintz@cavium.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
        Tomer.Tayar@cavium.com, Ram.Amrani@cavium.com,
        Manish.Rangankar@cavium.com, Chad.Dupuis@cavium.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:36261 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752132AbdCMXTv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 19:19:51 -0400
Content-Disposition: inline
In-Reply-To: <20170313.153347.308062967844295379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 03:33:47PM -0700, David Miller wrote:
> Applied, thanks.

So everyone who doesn't have the very latests linux-firmware will now
have a non-working card after upgrading the kernel?
