From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/macb: fix sparse warning
Date: Thu, 05 Feb 2015 16:06:12 -0800 (PST)
Message-ID: <20150205.160612.186602643427492859.davem@davemloft.net>
References: <1423153267-1768-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423153267-1768-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Thu,  5 Feb 2015 16:21:07 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> 
> macb.c:2038:26: warning: symbol 'gem_ethtool_ops' was not declared. Should it be static?
> 
> Alongside drops exporting of gem_ethtool_ops as there is no need.
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
