From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/5] ethernet: Use pci_(request|release)_mem_regions
Date: Wed, 1 Jun 2016 00:59:56 -0700
Message-ID: <20160601075956.GD11923@infradead.org>
References: <cover.1464694724.git.jthumshirn@suse.de>
 <3f24b687c31dea31a03cd3a529de790e942dd5bb.1464694724.git.jthumshirn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Johannes Thumshirn <jthumshirn@suse.de>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3f24b687c31dea31a03cd3a529de790e942dd5bb.1464694724.git.jthumshirn@suse.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2016 at 02:05:13PM +0200, Johannes Thumshirn wrote:
> Now that we do have pci_request_mem_regions() and pci_release_mem_regions() at
> hand, use it in the ethernet drivers.

This should probably be one patch per driver.
