From: 'Christoph Hellwig' <hch@lst.de>
Subject: Re: [PATCH 5/5] PCI: remove pci_enable_msix
Date: Mon, 27 Mar 2017 19:10:50 +0200
Message-ID: <20170327171050.GA28815@lst.de>
References: <20170327082936.6830-1-hch@lst.de> <20170327082936.6830-6-hch@lst.de> <063D6719AE5E284EB5DD2968C1650D6DCFFBAAD0@AcuExch.aculab.com> <20170327145135.GA24857@lst.de> <063D6719AE5E284EB5DD2968C1650D6DCFFBAC3E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Christoph Hellwig' <hch@lst.de>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netanel@annapurnalabs.com" <netanel@annapurnalabs.com>,
        "jcliburn@gmail.com" <jcliburn@gmail.com>,
        "chris.snook@gmail.com" <chris.snook@gmail.com>,
        "sgoutham@cavium.com" <sgoutham@cavium.com>,
        "rric@kernel.org" <rric@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42298 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751370AbdC0RMb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 13:12:31 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFBAC3E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 03:03:30PM +0000, David Laight wrote:
> Indeed, but pci_enable_msix_range() only appeared in 3.14.
> We have to support a wide range of kernels.
> I think we've finally managed to get most of our customers off 2.6.18.

That's your problem, not that of upstream kernel developers.
