From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: ethernet: cpsw: consider number of
 slaves in interation
Date: Tue, 26 Feb 2013 17:26:59 -0500 (EST)
Message-ID: <20130226.172659.1629171793131816809.davem@davemloft.net>
References: <1361887580-1770-1-git-send-email-zonque@gmail.com>
	<512CCCF2.7030306@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zonque@gmail.com, netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828Ab3BZW1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 17:27:01 -0500
In-Reply-To: <512CCCF2.7030306@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 26 Feb 2013 20:25:46 +0530

> On 2/26/2013 7:36 PM, Daniel Mack wrote:
>> Make cpsw_add_default_vlan() look at the actual number of slaves for
>> its
>> iteration, so boards with less than 2 slaves don't ooops at boot.
>>
>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> Cc: David S. Miller <davem@davemloft.net>
> Looks ok for me
> 
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
