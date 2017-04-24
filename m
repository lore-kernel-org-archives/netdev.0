From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 5/7] IB/hfi1: use pcie_flr instead of duplicating it
Date: Mon, 24 Apr 2017 16:35:07 +0200
Message-ID: <20170424143507.GA28812@lst.de>
References: <20170414191131.14286-1-hch@lst.de> <20170414191131.14286-6-hch@lst.de> <A33E225544E47D4DB5713032774B132783960382@irsmsx105.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        "Cabiddu, Giovanni" <giovanni.cabiddu@intel.com>,
        "Benedetto, Salvatore" <salvatore.benedetto@intel.com>,
        "Marciniszyn, Mike" <mike.marciniszyn@intel.com>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        qat-linux <qat-linux@intel.com>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.or
To: "Byczkowski, Jakub" <jakub.byczkowski@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <A33E225544E47D4DB5713032774B132783960382@irsmsx105.ger.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2017 at 02:16:31PM +0000, Byczkowski, Jakub wrote:
> Tested-by: Jakub Byczkowski <jakub.byczkowski@intel.com>

Are you (and Doug) ok with queueing this up in the PCI tree?
