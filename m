From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: sparse warning fixes
Date: Wed, 23 Jan 2008 20:54:25 -0800 (PST)
Message-ID: <20080123.205425.144643934.davem@davemloft.net>
References: <20080123154019.7cd9c471@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20080123154019.7cd9c471@deepthought>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 23 Jan 2008 15:40:19 -0800

> Fix a bunch of warnings in PPP and related drivers. Mostly because
> sparse doesn't like it when the the function is only marked private
> in the forward declaration.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
