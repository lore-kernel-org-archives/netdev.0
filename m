From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: smc91x: convert to dev_pm_ops
Date: Sun, 29 Nov 2009 00:21:42 -0800 (PST)
Message-ID: <20091129.002142.230416671.davem@davemloft.net>
References: <1259103467-31016-1-git-send-email-khilman@deeprootsystems.com>
	<alpine.LFD.2.00.0911242012500.2059@xanadu.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khilman@deeprootsystems.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nico@fluxnic.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754116AbZK2IVi@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0911242012500.2059@xanadu.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Pitre <nico@fluxnic.net>
Date: Tue, 24 Nov 2009 20:13:15 -0500 (EST)

> On Tue, 24 Nov 2009, Kevin Hilman wrote:
> 
>> Convert smc91x driver from legacy PM hooks over to using dev_pm_ops.
>> 
>> Tested on OMAP3 platform.
>> 
>> Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
> 
> Acked-by: Nicolas Pitre <nico@fluxnic.net>

Applied to net-next-2.6, thanks.
