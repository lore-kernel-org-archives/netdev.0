From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 11/12] netdev: octeon_mgmt: Convert to use
 device tree.
Date: Fri, 04 Mar 2011 13:10:39 -0800 (PST)
Message-ID: <20110304.131039.112585485.davem@davemloft.net>
References: <1299267744-17278-1-git-send-email-ddaney@caviumnetworks.com>
	<1299267744-17278-12-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ddaney@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299267744-17278-12-git-send-email-ddaney@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>
Date: Fri,  4 Mar 2011 11:42:23 -0800

> The device tree will supply the register bank base addresses, make
> register addressing relative to those.  PHY connection is now
> described by the device tree.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Acked-by: David S. Miller <davem@davemloft.net>
