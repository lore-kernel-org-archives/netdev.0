From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch arcnet over to initcalls
Date: Wed, 21 May 2003 16:20:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521.162052.08332261.davem@redhat.com>
References: <20030521221638.A7575@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030521221638.A7575@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Wed, 21 May 2003 22:16:38 +0200

   Link order already equals the old init order.  arcnet init/registration
   code still is more than fishy, maybe I'll look into that later.
   
ISA device init ordering again Christoph, com90xx is an ISA
driver...
