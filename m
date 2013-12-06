From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] macvtap: update file current position
Date: Thu, 05 Dec 2013 20:44:11 -0500 (EST)
Message-ID: <20131205.204411.86525521936068436.davem@davemloft.net>
References: <1386149341-10485-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab3LFBoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:44:13 -0500
In-Reply-To: <1386149341-10485-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Wed,  4 Dec 2013 17:29:00 +0800

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

The tun driver seems to have the same exact bug, please if you are going
to fix one then fix the other too.

Thanks.
