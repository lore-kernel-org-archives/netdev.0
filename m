From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: optimizing the code
Date: Tue, 24 Nov 2015 14:35:00 -0500 (EST)
Message-ID: <20151124.143500.2270041277109978016.davem@davemloft.net>
References: <1448285535-4514-1-git-send-email-saurabh.truth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: saurabh.truth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448285535-4514-1-git-send-email-saurabh.truth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Saurabh Sengar <saurabh.truth@gmail.com>
Date: Mon, 23 Nov 2015 19:02:15 +0530

> this patch does the following:
> 1 .  remove unnecessary if, else condition
> 2 .  reduce one variable
> 3 .  change the return type of 2 functions to void as there return values
> turn out to be 0 always after above changes
> 
> Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>

This looks fine, applied, thanks.
