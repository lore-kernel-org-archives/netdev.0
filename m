From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Set a "dsa" device_type
Date: Fri, 25 Sep 2015 12:25:44 -0700 (PDT)
Message-ID: <20150925.122544.1397732119363221370.davem@davemloft.net>
References: <1443057598-25729-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	linux@roeck-us.net, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932918AbbIYTZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 15:25:45 -0400
In-Reply-To: <1443057598-25729-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 23 Sep 2015 18:19:58 -0700

> Provide a device_type information for slave network devices created by
> DSA, this is useful for user-space application to easily locate/search
> for devices of a specific kind.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
