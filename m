From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] de4x5/PCI: use list_for_each_entry() for
 bus->devices traversal
Date: Mon, 19 Dec 2011 16:13:54 -0500 (EST)
Message-ID: <20111219.161354.690295963350650107.davem@davemloft.net>
References: <20111216223043.5963.87534.stgit@bhelgaas.mtv.corp.google.com>
	<20111216223154.5963.39965.stgit@bhelgaas.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, linux-pci@vger.kernel.org,
	grundler@parisc-linux.org, netdev@vger.kernel.org
To: bhelgaas@google.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20111216223154.5963.39965.stgit@bhelgaas.mtv.corp.google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 16 Dec 2011 15:31:54 -0700

> Replace open-coded list traversal with list_for_each_entry().
> 
> CC: Grant Grundler <grundler@parisc-linux.org>
> CC: netdev@vger.kernel.org
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Applied.
