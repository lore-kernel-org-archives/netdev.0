From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sh_eth: remove 'register_type' field from 'struct
 sh_eth_plat_data'
Date: Tue, 20 Aug 2013 17:05:41 -0700 (PDT)
Message-ID: <20130820.170541.1185336752082177256.davem@davemloft.net>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com>
	<201308180313.26607.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308180313.26607.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 18 Aug 2013 03:13:26 +0400

> Now that the 'register_type' field of the 'sh_eth' driver's platform data is not
> used by the driver anymore, it's time to remove it and  its initializers from
> the SH platform code. Also  move *enum* declaring values for this  field from
> <linux/sh_eth.h>  to  the  local driver's  header file as they're only needed
> by the driver itself  now...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
