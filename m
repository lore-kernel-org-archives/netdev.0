From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch iph5526_probe to initcalls
Date: Sun, 15 Jun 2003 11:03:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615.110358.10308169.davem@redhat.com>
References: <20030615180011.GA4922@lst.de>
	<20030615.105811.55734399.davem@redhat.com>
	<20030615180514.GA5006@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030615180514.GA5006@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Sun, 15 Jun 2003 20:05:14 +0200

   On Sun, Jun 15, 2003 at 10:58:11AM -0700, David S. Miller wrote:
   >    p.s. it doesn't compile with or without the patch due to scsi issues..
   >    
   > Can we put this patch on hold until that's resolved?
   
   Well, we could.  It's just that I doubt anyone will fix it anytime soon,
   the hardware doesn't seem to be widely used and it's hard to touch the
   driver without a barfbag nearby.

Ugh, ok.

At least it's impossible for you to break the tree
with this change. :)
