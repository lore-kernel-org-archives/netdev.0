From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch comx over to initcalls
Date: Mon, 19 May 2003 23:57:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030519.235734.55835721.davem@redhat.com>
References: <20030518190423.A28834@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030518190423.A28834@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Sun, 18 May 2003 19:04:24 +0200

   The link order already is the same as the old init order.  Note that the
   drivers are still full of crap, I don't have the hardware so I refuse to
   poke deeper into the shite..
   
Applied, thanks.
