From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -mm RESEND] net, rds, Replace xlist in net/rds/xlist.h
 with llist
Date: Thu, 15 Sep 2011 15:43:57 -0400 (EDT)
Message-ID: <20110915.154357.1768237553617962596.davem@davemloft.net>
References: <1314753690-31250-1-git-send-email-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	chris.mason@oracle.com, andy.grover@oracle.com
To: ying.huang@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314753690-31250-1-git-send-email-ying.huang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Huang Ying <ying.huang@intel.com>
Date: Wed, 31 Aug 2011 09:21:30 +0800

> The functionality of xlist and llist is almost same.  This patch
> replace xlist with llist to avoid code duplication.
> 
> Known issues: don't know how to test this, need special hardware?
> 
> Signed-off-by: Huang Ying <ying.huang@intel.com>

Applied.
