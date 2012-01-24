From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hyperv: fix possible memory leak in
 do_set_multicast()
Date: Tue, 24 Jan 2012 15:48:07 -0500 (EST)
Message-ID: <20120124.154807.720596846169960041.davem@davemloft.net>
References: <1327436488-24114-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yongjun_wei@trendmicro.com.cn
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327436488-24114-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 24 Jan 2012 12:21:28 -0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> do_set_multicast() may not free the memory malloc in
> netvsc_set_multicast_list().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
