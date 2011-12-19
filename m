From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] sunhme/PCI: use list_for_each_entry() for
 bus->devices traversal
Date: Mon, 19 Dec 2011 16:13:49 -0500 (EST)
Message-ID: <20111219.161349.1101987855765407439.davem@davemloft.net>
References: <20111216223043.5963.87534.stgit@bhelgaas.mtv.corp.google.com>
	<20111216223149.5963.61942.stgit@bhelgaas.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org
To: bhelgaas@google.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20111216223149.5963.61942.stgit@bhelgaas.mtv.corp.google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 16 Dec 2011 15:31:49 -0700

> Replace open-coded list traversal with list_for_each_entry().
> 
> CC: David S. Miller <davem@davemloft.net>
> CC: netdev@vger.kernel.org
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Applied.
