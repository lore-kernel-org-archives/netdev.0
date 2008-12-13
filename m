From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9][v2] mISDN: consistently define 'debug' as '*u_int'
Date: Fri, 12 Dec 2008 21:14:01 -0800 (PST)
Message-ID: <20081212.211401.140171586.davem@davemloft.net>
References: <49419a25.02e2660a.1ba9.6cda@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755303AbYLMFOP@vger.kernel.org>
In-Reply-To: <49419a25.02e2660a.1ba9.6cda@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 11 Dec 2008 22:36:00 +0100

> Impact: change data type for variable 'debug' from *int to *u_int,
> same for the argument type of mISDN_inittimer
> 
> In "core.h" mISDN_inittimer is declared with the argument type "*u_int", make
> the definition in "timerdev.c" match this.
> 
> This fixes also this warnings:
 ...
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> Acked-by: Karsten Keil <kkeil@suse.de>

Applied.
