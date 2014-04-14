From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cadence: Add architecture dependencies
Date: Mon, 14 Apr 2014 12:54:39 -0400 (EDT)
Message-ID: <20140414.125439.1807278146637759316.davem@davemloft.net>
References: <20140414141151.5ee5434d@endymion.delvare>
	<534BDBC9.8000509@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, netdev@vger.kernel.org, grant.likely@linaro.org,
	robh+dt@kernel.org
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862AbaDNQyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 12:54:41 -0400
In-Reply-To: <534BDBC9.8000509@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Mon, 14 Apr 2014 14:59:53 +0200

> Well, do we really need the adding of these dependencies? I though that
> we were moving toward the decreasing of dependency checks in Kconfig...

Yeah I really don't want to apply this, I like that this driver gets enabled
and compile tested when I do my standard allmodconfig/allyesconfig builds.
