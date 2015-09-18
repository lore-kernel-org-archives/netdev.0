From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] net: ks8851: Export OF module alias information
Date: Thu, 17 Sep 2015 21:24:29 -0700 (PDT)
Message-ID: <20150917.212429.1489441795356255015.davem@davemloft.net>
References: <1442394682-13801-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: javier@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442394682-13801-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier@osg.samsung.com>
Date: Wed, 16 Sep 2015 11:11:22 +0200

> Drivers needs to export the OF id table and this be built into
> the module or udev won't have the necessary information to autoload
> the driver module when the device is registered via OF.
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Applied.
