From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/3] xen-netback: Non-functional follow-up
 patch for grant mapping series
Date: Wed, 26 Mar 2014 16:34:01 -0400 (EDT)
Message-ID: <20140326.163401.1016704703453912598.davem@davemloft.net>
References: <1395705591-23976-1-git-send-email-zoltan.kiss@citrix.com>
	<1395705591-23976-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, paul.durrant@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jonathan.davies@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395705591-23976-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 24 Mar 2014 23:59:50 +0000

> Ian made some late comments about the grant mapping series, I incorporated the
> non-functional outcomes into this patch:
> 
> - typo fixes in a comment of xenvif_free(), and add another one there as well
> - typo fix for comment of rx_drain_timeout_msecs
> - remove stale comment before calling xenvif_grant_handle_reset()
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Applied.
