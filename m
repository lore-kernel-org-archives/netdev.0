From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] tg3: Convert to use
 hwmon_device_register_with_groups
Date: Thu, 28 Nov 2013 18:22:28 -0500 (EST)
Message-ID: <20131128.182228.1780515135706805369.davem@davemloft.net>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	<1385186881-7931-2-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, nsujir@broadcom.com, mchan@broadcom.com,
	e1000-devel@lists.sourceforge.net, lm-sensors@lm-sensors.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab3K1XWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:22:30 -0500
In-Reply-To: <1385186881-7931-2-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Fri, 22 Nov 2013 22:07:57 -0800

> Use new hwmon API to simplify code, provide missing mandatory 'name'
> sysfs attribute, and attach hwmon attributes to hwmon device instead
> of pci device.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.

Jeff Kirsher will pull the rest of this series in via his Intel ethernet
driver tree.
