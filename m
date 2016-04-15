From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH pci] pci: Add helper function to set VPD size
Date: Fri, 15 Apr 2016 11:30:26 -0500
Message-ID: <20160415163026.GA13979@localhost>
References: <1460657525-17551-1-git-send-email-hariprasad@chelsio.com>
 <00d801d1967c$68e9d100$3abd7300$@opengridcomputing.com>
 <571112D2.4010801@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhelgaas@google.com, 'Hariprasad Shenai' <hariprasad@chelsio.com>,
	davem@davemloft.net, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	santosh@chelsio.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <571112D2.4010801@opengridcomputing.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 11:12:02AM -0500, Steve Wise wrote:
> On 4/14/2016 1:35 PM, Steve Wise wrote:
> >>The fix is to add a PCI helper function to set the VPD size, so the
> >>driver can expicitly set the exact size of the VPD.
> >>
> >>Fixes commit 104daa71b396 ("PCI: Determine actual VPD size on first access")
> >>
> >>Signed-off-by: Casey Leedom <leedom@chelsio.com>
> >>Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> >Looks good!
> >Tested-by: Steve Wise <swise@opengridcomputing.com>
> >
> >
> 
> Hey Bjorn,
> 
> Will this make the next 4.6-rc?

No, it's too late for me to review it and merge it for v4.6-rc4.  But
there's still time for later RCs.

Bjorn
