From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: phy: Fix module autoload for OF platform
 drivers
Date: Mon, 21 Sep 2015 16:11:36 -0700 (PDT)
Message-ID: <20150921.161136.1004526057855335063.davem@davemloft.net>
References: <20150918161553.GA25782@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: luis@debethencourt.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150918161553.GA25782@goodgumbo.baconseed.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luis de Bethencourt <luis@debethencourt.com>
Date: Fri, 18 Sep 2015 18:15:53 +0200

> These patches add the missing MODULE_DEVICE_TABLE() for OF to export
> the information so modules have the correct aliases built-in and
> autoloading works correctly.
> 
> A longer explanation by Javier Canillas can be found here:
> https://lkml.org/lkml/2015/7/30/519
> 
> Sorry if these two patches should've been part of the ethernet series:
> https://lkml.org/lkml/2015/9/18/567

Series applied, thanks.
