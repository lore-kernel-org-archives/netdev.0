From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers:net:ifb: Fixed coding style error:assignment
 in if statement
Date: Tue, 20 Aug 2013 23:34:42 -0700 (PDT)
Message-ID: <20130820.233442.598967406878017552.davem@davemloft.net>
References: <1376955577-26518-1-git-send-email-skd.linux@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: skd.linux@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376955577-26518-1-git-send-email-skd.linux@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sanil Kumar D <skd.linux@gmail.com>
Date: Tue, 20 Aug 2013 05:09:37 +0530

> +	if (skb == NULL) {

"!skb" is preferred.

> +		if (skb == NULL) {

Likewise.
