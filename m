From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-04-11
Date: Mon, 11 Apr 2011 12:56:07 -0700 (PDT)
Message-ID: <20110411.125607.193710585.davem@davemloft.net>
References: <20110411193443.GD2511@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53177
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755718Ab1DKT4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 15:56:43 -0400
In-Reply-To: <20110411193443.GD2511@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 11 Apr 2011 15:34:43 -0400

> Here is another batch intended for 2.6.39.  Included is an mwl8k fix
> to avoid freeing an irq that we never requested, an ath common code
> fix to add a regulatory domain mapping code, an ath9k fix to avoid some
> crashes on MIPS boards and fix some radio stability issues on AR9285, a
> p54 fix to avoid a device lock-up caused by an uninitialized variable,
> an iwlagn fix to correct for an incorrect antenna configuration value
> in EEPROM on iwl5300 hardware, and an Kconfig fix for iwlegacy to
> keep old kernel build configurations still building iwl3945 and/or
> iwl4965 after the iwlagn/iwlegacy split.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
