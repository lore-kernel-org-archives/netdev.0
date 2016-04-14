From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [PATCH pci] pci: Add helper function to set VPD size
Date: Thu, 14 Apr 2016 13:35:25 -0500
Message-ID: <00d801d1967c$68e9d100$3abd7300$@opengridcomputing.com>
References: <1460657525-17551-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-pci@vger.kernel.org>, <netdev@vger.kernel.org>,
	<leedom@chelsio.com>, <nirranjan@chelsio.com>,
	<santosh@chelsio.com>
To: "'Hariprasad Shenai'" <hariprasad@chelsio.com>,
	<bhelgaas@google.com>, <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1460657525-17551-1-git-send-email-hariprasad@chelsio.com>
Content-Language: en-us
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The fix is to add a PCI helper function to set the VPD size, so the
> driver can expicitly set the exact size of the VPD.
> 
> Fixes commit 104daa71b396 ("PCI: Determine actual VPD size on first access")
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Looks good!
  
Tested-by: Steve Wise <swise@opengridcomputing.com>
