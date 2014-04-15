From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Tue, 15 Apr 2014 00:08:37 -0400 (EDT)
Message-ID: <20140415.000837.1888474702311972162.davem@davemloft.net>
References: <20140414153849.7138699b@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com,
	grant.likely@linaro.org, robh+dt@kernel.org
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaDOEIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 00:08:40 -0400
In-Reply-To: <20140414153849.7138699b@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Mon, 14 Apr 2014 15:38:49 +0200

> The Cadence ethernet chipsets are only used on specific ARM
> architectures. Add Kconfig dependencies so that drivers for these
> chipsets are only buildable on the relevant architectures.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied.
