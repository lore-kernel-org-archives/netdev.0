From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch iph5526_probe to initcalls
Date: Sun, 15 Jun 2003 10:58:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615.105811.55734399.davem@redhat.com>
References: <20030615180011.GA4922@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030615180011.GA4922@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Sun, 15 Jun 2003 20:00:11 +0200

   It's a pci driver so it has no business in Space.c
   
   p.s. it doesn't compile with or without the patch due to scsi issues..
   
Can we put this patch on hold until that's resolved?
Thanks.
