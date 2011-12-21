From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net: ethernet: xilinx: Don't use NO_IRQ in xilinx
Date: Wed, 21 Dec 2011 15:43:02 -0500 (EST)
Message-ID: <20111221.154302.206106800367957142.davem@davemloft.net>
References: <1324477932-19262-1-git-send-email-monstr@monstr.eu>
	<1324477932-19262-2-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, sfr@canb.auug.org.au,
	grant.likely@secretlab.ca, rmallon@gmail.com
To: monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324477932-19262-2-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <monstr@monstr.eu>
Date: Wed, 21 Dec 2011 15:32:10 +0100

> Fix ll_temac and emaclite drivers. Only Microblaze and Xilinx PPC
> use then and both use NO_IRQ as 0. It will be removed in near future.
> 
> Signed-off-by: Michal Simek <monstr@monstr.eu>

Applied, thanks.
