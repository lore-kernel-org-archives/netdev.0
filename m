From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: use msecs_to_jiffies for conversions
Date: Fri, 30 Jan 2015 18:08:45 -0800 (PST)
Message-ID: <20150130.180845.1277305322177298613.davem@davemloft.net>
References: <1422552171-25947-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: der.herr@hofr.at
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422552171-25947-1-git-send-email-der.herr@hofr.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <der.herr@hofr.at>
Date: Thu, 29 Jan 2015 18:22:51 +0100

> This is only an API consolidation and should make things more readable
> it replaces  var * HZ / 1000  constructs by  msecs_to_jiffies(var).
> 
> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>

Applied to net-next, thanks.
