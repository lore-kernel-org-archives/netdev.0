From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.4.20] vanilla 3c59x
Date: Fri, 13 Dec 2002 00:26:51 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021213002651.A15922@infradead.org>
References: <3DF925AC.4020703@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3DF925AC.4020703@pobox.com>; from jgarzik@pobox.com on Thu, Dec 12, 2002 at 07:11:24PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 12, 2002 at 07:11:24PM -0500, Jeff Garzik wrote:
> 
> 	bk pull bk://kernel.bkbits.net/jgarzik/3c59x-2.4
> 
> This will update the following files:

Marcelo, please don't pull that.  Having the pci-scan* junk in mainline
is bogus.
