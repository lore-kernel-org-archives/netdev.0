From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: fix sparse warning
Date: Thu, 05 Feb 2015 16:04:44 -0800 (PST)
Message-ID: <20150205.160444.1773599790144004658.davem@davemloft.net>
References: <1423143487-4722-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423143487-4722-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Thu,  5 Feb 2015 13:38:07 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> 
> interface.c:83:5: warning: symbol 'xenvif_poll' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
