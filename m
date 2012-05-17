From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] drivers/net: delete all code/drivers depending on
 CONFIG_MCA
Date: Thu, 17 May 2012 18:23:27 -0400 (EDT)
Message-ID: <20120517.182327.996399544318392752.davem@davemloft.net>
References: <1337272841-25931-3-git-send-email-paul.gortmaker@windriver.com>
	<4FB52C99.6010303@windriver.com>
	<20120517212039.GC27789@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, JBottomley@parallels.com,
	netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120517212039.GC27789@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 17 May 2012 17:20:39 -0400

> I've layered the above commit (with 3c527.h deleted) onto today's
> net-next, did a quick re-test of x86_64 allmodconfig and put it
> on a branch as per below (vs sending a 5000+ line patch).
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git delete-mca-net-drivers

Pulled, thanks Paul.
