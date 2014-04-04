From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: hisilicon: new hip04 MDIO driver
Date: Fri, 04 Apr 2014 11:43:04 -0400 (EDT)
Message-ID: <20140404.114304.1006318624302104151.davem@davemloft.net>
References: <1396624597-390-3-git-send-email-zhangfei.gao@linaro.org>
	<20140404.113010.1212333214715849484.davem@davemloft.net>
	<533ED268.9090502@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: zhangfei.gao@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbaDDPla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 11:41:30 -0400
In-Reply-To: <533ED268.9090502@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: zhangfei <zhangfei.gao@linaro.org>
Date: Fri, 04 Apr 2014 23:40:24 +0800

> Thanks Daivd, could I update following this thread first.

You will need to address my feedback, as well as that which anyone
else reviewing this series gives to you.

It is not acceptable, ever, to "just fix it later".  You must fix
all issues pointed out to you before your code will be integrated.
