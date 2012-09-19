From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdev: make address const in device address
 management
Date: Wed, 19 Sep 2012 16:38:43 -0400 (EDT)
Message-ID: <20120919.163843.619383347495203920.davem@davemloft.net>
References: <20120917130326.028dac29@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab2ISUiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 16:38:46 -0400
In-Reply-To: <20120917130326.028dac29@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Sep 2012 13:03:26 -0700

> The internal functions for add/deleting addresses don't change
> their argument.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
