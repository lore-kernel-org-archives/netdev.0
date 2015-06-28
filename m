From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dsa: fix promiscuity leak on slave dev open error
Date: Sun, 28 Jun 2015 16:57:20 -0700 (PDT)
Message-ID: <20150628.165720.6985165938262975.davem@davemloft.net>
References: <1435240213-15179-1-git-send-email-giladb@ezchip.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gilad@benyossef.com, f.fainelli@gmail.com,
	linux@roeck-us.net, andrew@lunn.ch, sfeldma@gmail.com
To: giladb@ezchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbbF1X5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 19:57:21 -0400
In-Reply-To: <1435240213-15179-1-git-send-email-giladb@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <giladb@ezchip.com>
Date: Thu, 25 Jun 2015 16:50:13 +0300

> From: Gilad Ben-Yossef <gilad@benyossef.com>
> 
> DSA master netdev promiscuity counter was not being properly
> decremented on slave device open error path.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>

Applied.
