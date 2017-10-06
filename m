From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Use pci_ari_enabled() instead of local copy
Date: Fri, 06 Oct 2017 10:10:24 -0700 (PDT)
Message-ID: <20171006.101024.669294369860767964.davem@davemloft.net>
References: <20171006110030.10980.52268.stgit@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@cavium.com, netdev@vger.kernel.org,
        everest-linux-l2@cavium.com, linux-kernel@vger.kernel.org
To: helgaas@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171006110030.10980.52268.stgit@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 06 Oct 2017 06:00:30 -0500

> From: Bjorn Helgaas <bhelgaas@google.com>
> 
> Use pci_ari_enabled() from the PCI core instead of the identical local copy
> bnx2x_ari_enabled().  No functional change intended.
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Applied to net-next.
