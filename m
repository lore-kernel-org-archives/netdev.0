From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cadence: Add architecture dependencies
Date: Mon, 14 Apr 2014 13:34:31 -0400 (EDT)
Message-ID: <20140414.133431.2093767162311938311.davem@davemloft.net>
References: <534BDBC9.8000509@atmel.com>
	<20140414.125439.1807278146637759316.davem@davemloft.net>
	<20140414191438.444d6ed8@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	grant.likely@linaro.org, robh+dt@kernel.org
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755077AbaDNRed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 13:34:33 -0400
In-Reply-To: <20140414191438.444d6ed8@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Mon, 14 Apr 2014 19:14:38 +0200

> Hi David,
> 
> On Mon, 14 Apr 2014 12:54:39 -0400 (EDT), David Miller wrote:
>> From: Nicolas Ferre <nicolas.ferre@atmel.com>
>> Date: Mon, 14 Apr 2014 14:59:53 +0200
>> 
>> > Well, do we really need the adding of these dependencies? I though that
>> > we were moving toward the decreasing of dependency checks in Kconfig...
>> 
>> Yeah I really don't want to apply this, I like that this driver gets enabled
>> and compile tested when I do my standard allmodconfig/allyesconfig builds.
> 
> They will still be. allmodconfig/allyesconfig enables COMPILE_TEST. Is
> the world not wonderful? :)

Ok I'm not so against this then :)
