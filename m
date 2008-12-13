From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9][v2] mISDN: fix sparse warning: symbol 'nskb'
 shadows an earlier one
Date: Fri, 12 Dec 2008 21:17:08 -0800 (PST)
Message-ID: <20081212.211708.144435933.davem@davemloft.net>
References: <49419a31.0aa1660a.486c.07b8@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756493AbYLMFRT@vger.kernel.org>
In-Reply-To: <49419a31.0aa1660a.486c.07b8@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 11 Dec 2008 22:36:00 +0100

> Impact: define first occurence of variable 'nskb' in inner most possible scope
> 
> Fix this sparse warning:
> 
>   drivers/isdn/mISDN/dsp_core.c:746:20: warning: symbol 'nskb' shadows an earlier one
>   drivers/isdn/mISDN/dsp_core.c:634:19: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> Acked-by: Karsten Keil <kkeil@suse.de>

Applied.
