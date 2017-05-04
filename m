From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: CPU: 2 PID: 682 at net/wireless/util.c:1236
Date: Thu, 04 May 2017 11:25:12 -0400 (EDT)
Message-ID: <20170504.112512.833061289089590605.davem@davemloft.net>
References: <240bae44-56e4-f342-0d1b-358a573e2eeb@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linuxwifi@intel.com,
        johannes.berg@intel.com
To: axboe@kernel.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752659AbdEDPZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:25:13 -0400
In-Reply-To: <240bae44-56e4-f342-0d1b-358a573e2eeb@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Axboe <axboe@kernel.dk>
Date: Thu, 4 May 2017 09:23:36 -0600

> Running current -git on my laptop, and I see this spew every once
> in a while. This is new, haven't seen it in 4.11 or previously. Driver
> is iwlwifi:

Please try:

http://patchwork.ozlabs.org/patch/758364/
