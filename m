From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] move dmascc away from setup.c
Date: Tue, 03 Jun 2003 22:13:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.221313.70195889.davem@redhat.com>
References: <20030603082326.GA22946@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030603082326.GA22946@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Tue, 3 Jun 2003 10:23:26 +0200

   Yeah, it's a isa driver but it already was in the setup.c
   pci probes list.
   
   Also use SET_MODULE_OWNER instead of MOD_{INC,DEC}_USE_COUNT.
   
Applied, thanks.
