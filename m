From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxge: Add const to ethtool_driver_stats_keys
Date: Wed, 01 Apr 2015 15:35:35 -0400 (EDT)
Message-ID: <20150401.153535.1962828889964755786.davem@davemloft.net>
References: <1427916553.31790.70.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427916553.31790.70.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 01 Apr 2015 12:29:13 -0700

> Move about half a KB of data to text.
> 
> Miscellanea:
> 
> o Move strings out of the .h file into the .c file
>   in case the .h file is ever #included twice
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
