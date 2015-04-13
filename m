From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5 v4] netfilter: Fix portid types
Date: Mon, 13 Apr 2015 16:35:40 -0400 (EDT)
Message-ID: <20150413.163540.64651067198865466.davem@davemloft.net>
References: <1428879159-19237-1-git-send-email-richard@nod.at>
	<1428879159-19237-3-git-send-email-richard@nod.at>
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
In-Reply-To: <1428879159-19237-3-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>
Date: Mon, 13 Apr 2015 00:52:37 +0200

> The netlink portid is an unsigned integer, use this type
> also in netfilter.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

Applied.
