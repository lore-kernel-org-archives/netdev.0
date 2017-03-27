From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/5] net: thunderx: switch to pci_alloc_irq_vectors
Date: Mon, 27 Mar 2017 19:12:40 +0200
Message-ID: <20170327171240.GC28815@lst.de>
References: <20170327082936.6830-1-hch@lst.de> <20170327082936.6830-2-hch@lst.de> <CA+sq2CdsGPNwU0kKQUtRgxKvGTDoYE0yLVC+fSgc3DGbjOjWVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        "David S. Miller" <davem@davemloft.net>, netanel@annapurnalabs.com,
        jcliburn@gmail.com, chris.snook@gmail.com,
        Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-pci <linux-pci@vger.kernel.org>
To: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+sq2CdsGPNwU0kKQUtRgxKvGTDoYE0yLVC+fSgc3DGbjOjWVg@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 27, 2017 at 09:33:32PM +0530, Sunil Kovvuri wrote:
> How urgent is this ?

I would like to get this into 4.12 to stop people from adding new users of
pci_enable_msix.

> Can we comeup with a proper patch to fix this in couple of weeks, instead of
> going with these untested patches ?

Sure.
