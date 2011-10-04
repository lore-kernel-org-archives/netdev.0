From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] NET: white space/coding style cleanup of asix
 driver
Date: Tue, 04 Oct 2011 16:26:26 -0400 (EDT)
Message-ID: <20111004.162626.728021061418588859.davem@davemloft.net>
References: <1317758118-24052-1-git-send-email-grundler@chromium.org>
	<1317758118-24052-3-git-send-email-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw
To: grundler@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317758118-24052-3-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@chromium.org>
Date: Tue,  4 Oct 2011 12:55:18 -0700

> check patch was complaining...mostly replaced:
>    if ((ret = asix_foo(xx)) < 0) ...
> with
>    ret = asix_foo(xx);
>    if (ret < 0) ...
> 
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Applied to net-next-2.6
