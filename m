From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] kill acient compat cruft from acenic
Date: Fri, 27 Feb 2004 15:55:41 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403FAECD.3090203@pobox.com>
References: <20040227202510.GA19947@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040227202510.GA19947@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> Kills lots of really old cruft and adds a little cruft to actually
> make the driver work with recent 2.4 again.


Since kcompat (http://sf.net/projects/gkernel/) lets PCI API drivers 
work in 2.2, 2.4 and 2.6, I am OK with applying this patch...... 
assuming there is a second patch coming to convert to pci_driver API.

	Jeff
