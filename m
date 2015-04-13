From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 v4] netlink: Fix portid type in netlink_notify
Date: Mon, 13 Apr 2015 16:35:29 -0400 (EDT)
Message-ID: <20150413.163529.25460892277772842.davem@davemloft.net>
References: <1428879159-19237-1-git-send-email-richard@nod.at>
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
In-Reply-To: <1428879159-19237-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>
Date: Mon, 13 Apr 2015 00:52:35 +0200

> portid is an unsigned integer. Fix netlink_notify to
> match all other portid user in the kernel.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

Applied.
