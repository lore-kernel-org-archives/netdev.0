From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Fri, 28 Mar 2014 16:00:24 -0400 (EDT)
Message-ID: <20140328.160024.136488246522581222.davem@davemloft.net>
References: <1395400154-25710-1-git-send-email-ben.dooks@codethink.co.uk>
	<20140328.142606.2032782733436495474.davem@davemloft.net>
	<5335CCBF.8030606@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	laurent.pinchart+renesas@ideasonboard.com
To: ben.dooks@codethink.co.uk
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5335CCBF.8030606@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Fri, 28 Mar 2014 19:25:51 +0000

> I thought it was against the net next tree, given the number of
> patches that are currently being applied to the sh_eth driver.

Fair enough, applied to net-next, thanks!
