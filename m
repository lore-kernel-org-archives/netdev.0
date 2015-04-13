From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/5 v4] netfilter: Fix portid types
Date: Mon, 13 Apr 2015 20:43:19 +0200
Message-ID: <20150413184319.GA3333@salvia>
References: <1428879159-19237-1-git-send-email-richard@nod.at>
 <1428879159-19237-3-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, sameo@linux.intel.com,
	aloisio.almeida@openbossa.org, lauro.venancio@openbossa.org,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1428879159-19237-3-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 13, 2015 at 12:52:37AM +0200, Richard Weinberger wrote:
> The netlink portid is an unsigned integer, use this type
> also in netfilter.
>
> Signed-off-by: Richard Weinberger <richard@nod.at>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
