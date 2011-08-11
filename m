From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] scm: Capture the full credentials of the scm sender
Date: Thu, 11 Aug 2011 05:51:33 -0700 (PDT)
Message-ID: <20110811.055133.301483708516642472.davem@davemloft.net>
References: <1312841316.2576.49.camel@schen9-DESK>
	<1312857834.2531.15.camel@edumazet-laptop>
	<1312908512.2576.97.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ebiederm@xmission.com,
	viro@zeniv.linux.org.uk, ak@linux.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tim.c.chen@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312908512.2576.97.camel@schen9-DESK>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 09 Aug 2011 09:48:32 -0700

> This patch corrects an erroneous update of credential's gid with uid
> introduced in commit 257b5358b32f17 since 2.6.36.
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Applied, thanks.
