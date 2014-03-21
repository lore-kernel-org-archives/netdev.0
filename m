From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: Follow-up patch for grant
 mapping series
Date: Fri, 21 Mar 2014 14:13:09 -0400 (EDT)
Message-ID: <20140321.141309.1420639327487993718.davem@davemloft.net>
References: <1395343961-4744-1-git-send-email-zoltan.kiss@citrix.com>
	<1395343961-4744-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, paul.durrant@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jonathan.davies@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395343961-4744-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Thu, 20 Mar 2014 19:32:41 +0000

> Ian made some late comments about the grant mapping series, I incorporated the
> outcomes into this patch. Additional comments, refactoring etc.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

I would really prefer that pure non-functional cleanup changes happen
separately from real changes.

Thanks.
