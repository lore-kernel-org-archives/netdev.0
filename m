From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hyperv: fix sparse warnings
Date: Thu, 05 Feb 2015 16:05:17 -0800 (PST)
Message-ID: <20150205.160517.2179324348333657027.davem@davemloft.net>
References: <1423148793-19610-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423148793-19610-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Thu,  5 Feb 2015 15:06:33 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warnings:
> 
> netvsc.c:688:5: warning: symbol 'netvsc_copy_to_send_buf' was not declared. Should it be static?
> rndis_filter.c:627:5: warning: symbol 'rndis_filter_set_offload_params' was not declared. Should it be static?
> rndis_filter.c:702:5: warning: symbol 'rndis_filter_set_rss_param' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
