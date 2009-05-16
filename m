From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2009-05-12
Date: Sat, 16 May 2009 13:33:33 -0700 (PDT)
Message-ID: <20090516.133333.92480462.davem@davemloft.net>
References: <20090512145423.GA3773@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45305
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278AbZEPUdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 16:33:35 -0400
In-Reply-To: <20090512145423.GA3773@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 12 May 2009 10:54:24 -0400

> Another round of fixes intended for 2.6.30.  In particular, "mac80211:
> avoid NULL ptr deref when finding max_rates in PID and minstrel" fixes a
> bug that is a by-product of a fix that has already gone to Linus...oops!
> As for the others, the iwlwifi patch adds PCI IDs and corrects antenna
> configurations for a couple of devices, the rtl8187 corrects a problem
> some people were hitting relating to using non-DMA buffers for USB
> messages, the airo fix corrects an possible buffer overflow, and the
> ath5k fix documents the oops it is correcting.

Pulled, Thanks John.  I'll try to get this to Linus over the
weekend.
