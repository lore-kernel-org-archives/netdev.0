From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9][v2] mISDN: fix sparse warning: symbol 'id' shadows
 an earlier one
Date: Fri, 12 Dec 2008 21:17:46 -0800 (PST)
Message-ID: <20081212.211746.16355480.davem@davemloft.net>
References: <49419a37.0aa5660a.7d74.31a0@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752211AbYLMFR5@vger.kernel.org>
In-Reply-To: <49419a37.0aa5660a.7d74.31a0@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 11 Dec 2008 22:36:00 +0100

> Impact: rename function scope variable
> 
> Fix this warning:
> 
>   drivers/isdn/mISDN/l1oip_core.c:472:8: warning: symbol 'id' shadows an earlier one
>   drivers/isdn/mISDN/l1oip_core.c:254:14: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> Acked-by: Karsten Keil <kkeil@suse.de>

Applied.
