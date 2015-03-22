From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/18] net: dsa: HW bridging, EEE support
Date: Sat, 21 Mar 2015 22:14:50 -0400 (EDT)
Message-ID: <20150321.221450.2007372852150941507.davem@davemloft.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
	<20150321.184817.575148530596089433.davem@davemloft.net>
	<550DFADE.1080209@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbbCVCOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 22:14:55 -0400
In-Reply-To: <550DFADE.1080209@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Sat, 21 Mar 2015 16:12:30 -0700

> Yes, agreed. It is on the to-do list. Should we be more aggressive ?
> Since I'll have to resubmit anyway, we could start by adding defines
> for all constants used in this patch set, not just some of them.

As long as you'll really take care of this afterwards, you can take
care of the defines after this series is integrated.
