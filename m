From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: ethtool: Added port speed macros.
Date: Mon, 18 May 2015 11:46:30 -0400 (EDT)
Message-ID: <20150518.114630.1938175226193925552.davem@davemloft.net>
References: <1431946907-7808-1-git-send-email-parav.pandit@avagotech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bwh@kernel.org
To: parav.pandit@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011AbbERPqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:46:35 -0400
In-Reply-To: <1431946907-7808-1-git-send-email-parav.pandit@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parav Pandit <parav.pandit@avagotech.com>
Date: Mon, 18 May 2015 16:31:47 +0530

> Signed-off-by: Parav Pandit <parav.pandit@avagotech.com>

I thought we had decided that we weren't going to keep adding
convenience macros for new speeds, and were simply going to use
the appropriate constants in the future.

Ben?
