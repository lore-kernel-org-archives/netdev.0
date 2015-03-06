From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Correct the MID field length value
Date: Thu, 05 Mar 2015 22:19:37 -0500 (EST)
Message-ID: <20150305.221937.961006553503651166.davem@davemloft.net>
References: <781b35c13921854b0a8d860b727f8ac86147768a.1425564128.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, monstr@monstr.eu, zachp@xilinx.com,
	punnaiah.choudary.kalluri@xilinx.com, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <781b35c13921854b0a8d860b727f8ac86147768a.1425564128.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Thu,  5 Mar 2015 15:02:10 +0100

> From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
> 
> The latest spec "I-IPA01-0266-USR Rev 10" limit the MID field length to 12 bit
> value. For previous versions it is 16 bit value.
> 
> This change will not break the backward compatibility as the latest ID value is
> 7 and with in the 12 bit value limit.
> 
> Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied, thanks.
