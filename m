From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MAINTAINERS: Intel nic drivers
Date: Wed, 26 Feb 2014 15:50:24 -0500 (EST)
Message-ID: <20140226.155024.719059614598164102.davem@davemloft.net>
References: <1393364153.8716.63.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393364153.8716.63.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 25 Feb 2014 13:35:53 -0800

> Add a new F: line for the intel subdirectories.
> 
> This allows get_maintainers to avoid using git log
> and cc'ing people that have submitted clean-up style
> patches for all first level directories under
> drivers/net/ethernet/intel/
> 
> This does not make e100.c maintained.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
