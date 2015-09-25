From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove unused argument of
 __netdev_find_adj()
Date: Fri, 25 Sep 2015 12:35:42 -0700 (PDT)
Message-ID: <20150925.123542.859745227026880248.davem@davemloft.net>
References: <20150924085905.5ADC2A572E@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150924085905.5ADC2A572E@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu, 24 Sep 2015 10:59:05 +0200 (CEST)

> The __netdev_find_adj() helper does not use its first argument, only the
> device to find and list to walk through.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied, thank you.
