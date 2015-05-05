From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hv_netvsc: remove unused variable in netvsc_send()
Date: Tue, 05 May 2015 17:31:23 -0400 (EDT)
Message-ID: <20150505.173123.1768860135204113385.davem@davemloft.net>
References: <1430762236-18660-1-git-send-email-jsnitsel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@linuxdriverproject.org, haiyangz@microsoft.com,
	kys@microsoft.com
To: jsnitsel@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430762236-18660-1-git-send-email-jsnitsel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jerry Snitselaar <jsnitsel@redhat.com>
Date: Mon,  4 May 2015 10:57:16 -0700

> With commit b56fc3c53654 ("hv_netvsc: Fix a bug in netvsc_start_xmit()"),
> skb variable is no longer used in netvsc_send. Remove variable and dead
> code that depended on it.
> 
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Signed-off-by: Jerry Snitselaar <jsnitsel@redhat.com>

Applied, thanks.
