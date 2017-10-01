From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net: ipmr: make function ipmr_notifier_init
 static
Date: Sun, 01 Oct 2017 04:07:21 +0100 (WEST)
Message-ID: <20171001.040721.1898715383953902696.davem@davemloft.net>
References: <20170929133422.7846-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: colin.king@canonical.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170929133422.7846-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 29 Sep 2017 14:34:22 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The function ipmr_notifier_init is local to the source and does
> not need to be in global scope, so make it static.
> 
> Cleans up sparse warning:
> warning: symbol 'ipmr_notifier_init' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thank you.
