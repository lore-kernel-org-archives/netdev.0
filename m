From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [ANN] removal of certain net drivers coming soon: eepro100, xircom_tulip_cb, iph5526
Date: Thu, 27 Jan 2005 21:07:31 +0000
Message-ID: <20050127210731.GA2953@infradead.org>
References: <41F952F4.7040804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Netdev <netdev@oss.sgi.com>,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41F952F4.7040804@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2005 at 03:45:40PM -0500, Jeff Garzik wrote:
> 1) iphase (iph5526 a.k.a. drivers/net/fc/*)
> 
> Been broken since 2.3 or 2.4.  Only janitors have kept it compiling.

No, it doesn't even compile, and didn't so for more than two years.
