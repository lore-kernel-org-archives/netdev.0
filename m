From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5 v4] netfilter: Fix format string of nfnetlink_log
 proc file
Date: Mon, 13 Apr 2015 16:35:52 -0400 (EDT)
Message-ID: <20150413.163552.745090447524548507.davem@davemloft.net>
References: <1428879159-19237-1-git-send-email-richard@nod.at>
	<1428879159-19237-5-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, sameo@linux.intel.com,
	aloisio.almeida@openbossa.org, lauro.venancio@openbossa.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org
To: richard@nod.at
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428879159-19237-5-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>
Date: Mon, 13 Apr 2015 00:52:39 +0200

> The printed values are all of type unsigned integer, therefore use
> %u instead of %d. Otherwise an user can face negative values.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

Applied.
