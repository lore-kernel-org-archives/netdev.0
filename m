From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] net: Fix module autoload for OF platform drivers
Date: Mon, 21 Sep 2015 16:09:56 -0700 (PDT)
Message-ID: <20150921.160956.1076951919224201109.davem@davemloft.net>
References: <20150918155332.GA24705@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	f.fainelli@gmail.com, richardcochran@gmail.com, wsa@the-dreams.de,
	joe@perches.com, tklauser@distanz.ch
To: luis@debethencourt.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150918155332.GA24705@goodgumbo.baconseed.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luis de Bethencourt <luis@debethencourt.com>
Date: Fri, 18 Sep 2015 17:53:32 +0200

> Hi,
> 
> These patches add the missing MODULE_DEVICE_TABLE() for OF to export
> the information so modules have the correct aliases built-in and
> autoloading works correctly.
> 
> A longer explanation by Javier Canillas can be found here:
> https://lkml.org/lkml/2015/7/30/519

ks8851 already has this issue fixed, thus rest of series
applied, thanks.
