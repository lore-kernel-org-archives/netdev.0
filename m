From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] gianfar: add missing include
Date: Tue, 10 Apr 2012 08:36:42 +0200
Message-ID: <20120410063641.GA10025@localhost.localdomain>
References: <25411.1334031527@neuling.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-next@vger.kernel.org
To: Michael Neuling <mikey@neuling.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <25411.1334031527@neuling.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 02:18:47PM +1000, Michael Neuling wrote:
> This is because of a missing include file from:
>   6663628 gianfar: Support the get_ts_info ethtool method.
> 
> Signed-off-by: Michael Neuling <mikey@neuling.org>

I did a poor job testing the non-x86 stuff in this series.  Thanks for
the fix.

Acked-by: Richard Cochran <richardcochran@gmail.com>
