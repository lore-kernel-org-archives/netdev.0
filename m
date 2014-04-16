From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: mdio-gpio: Use devm_ functions where possible
Date: Tue, 15 Apr 2014 23:17:06 -0400 (EDT)
Message-ID: <20140415.231706.812725635915796409.davem@davemloft.net>
References: <1397614602-29694-1-git-send-email-linux@roeck-us.net>
	<1397614602-29694-2-git-send-email-linux@roeck-us.net>
	<724F6C6CDC8C86478473775085778C4E09E85E3A@ImsEx1.ims.dom>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	cphealy@gmail.com
To: chealy@imsco-us.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <724F6C6CDC8C86478473775085778C4E09E85E3A@ImsEx1.ims.dom>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Healy <chealy@imsco-us.com>
Date: Wed, 16 Apr 2014 02:50:08 +0000

> This simplifies error path and deinit/removal functions.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> Tested-by: Chris Healy <cphealy@gmail.com>

This isn't the way to add a Tested-by: tag of your own if that
is what you're trying to do.

The proper way is to reply to the original patch, quote only the
commit message, and then add your Tested-by: after the quoted
material.
