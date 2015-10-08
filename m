From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-octeon: Drop obsolete Kconfig advice
Date: Thu, 08 Oct 2015 05:12:36 -0700 (PDT)
Message-ID: <20151008.051236.1458635578045299176.davem@davemloft.net>
References: <20151007102638.335e9762@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, sgoutham@cavium.com,
	rchintakuntla@cavium.com, david.daney@cavium.com
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756931AbbJHL4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 07:56:49 -0400
In-Reply-To: <20151007102638.335e9762@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Wed, 7 Oct 2015 10:26:38 +0200

> "Y" was the right answer for MDIO_OCTEON when this option was only
> available on CAVIUM_OCTEON_SOC. But now that the option is visible on
> all (64-bit) systems, this piece of advice no longer makes sense. This
> helper module is selected automatically by drivers which need it
> anyway.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Fixes: a6d6786452 ("net: mdio-octeon: Modify driver to work on both ThunderX and Octeon")

Applied, thank you.
