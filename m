From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] NCSI VLAN Filtering Support
Date: Fri, 11 Aug 2017 14:48:23 -0700 (PDT)
Message-ID: <20170811.144823.1928647996484981190.davem@davemloft.net>
References: <20170811061648.19661-1-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        openbmc@lists.ozlabs.org, joel@jms.id.au, benh@kernel.crashing.org,
        gwshan@linux.vnet.ibm.com, ratagupt@in.ibm.com
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170811061648.19661-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Fri, 11 Aug 2017 16:16:45 +1000

> This series (mainly patch 3) adds VLAN filtering to the NCSI implementation.
> A fair amount of code already exists in the NCSI stack for VLAN filtering but
> none of it is actually hooked up. This goes the final mile and fixes a few
> bugs in the existing code found along the way (patch 2).
> 
> Patch 1 adds the appropriate flag to the ftgmac100 driver to enable filtering
> as it's a large consumer of NCSI (and what I've been testing on).

This patch series does not apply cleanly to net-next, you need to respin.
