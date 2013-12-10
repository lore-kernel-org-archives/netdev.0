From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] New ARPHRD type for 6LoWPAN
Date: Mon, 09 Dec 2013 21:06:29 -0500 (EST)
Message-ID: <20131209.210629.1931927418156313725.davem@davemloft.net>
References: <1386439737-14894-1-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jukka.rissanen@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab3LJCGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:06:31 -0500
In-Reply-To: <1386439737-14894-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Date: Sat,  7 Dec 2013 20:08:55 +0200

> new ARPHRD needed for 6LoWPAN networks. Initially this will
> be used by Bluetooth sub-system but IEEE 802154 will be converted
> to use it also. The patch using this new ARPHRD is sent to
> bluetooth mailing list.

Please add this to the tree when the bluetooth code that uses it
is added, you can add my:

Acked-by: David S. Miller <davem@davemloft.net>

when you do so.
