From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch skfp over to initcalls
Date: Mon, 09 Jun 2003 09:51:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.095106.22030084.davem@redhat.com>
References: <20030609120603.GA31393@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030609120603.GA31393@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Mon, 9 Jun 2003 14:06:03 +0200

   This is a PCI driver and has no business in Space.c.  Also
   allows to kill all the fddi code in there (and the stale
   reference to the long gone apfddi driver)
   
Applied, thanks.
