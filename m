From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Add vxlan RSS support
Date: Tue, 18 Aug 2015 14:21:35 -0700 (PDT)
Message-ID: <20150818.142135.455807492677912406.davem@davemloft.net>
References: <1439882579-16136-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Rajesh.Borundia@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbbHRVVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 17:21:37 -0400
In-Reply-To: <1439882579-16136-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 18 Aug 2015 10:22:59 +0300

> From: Rajesh Borundia <Rajesh.Borundia@qlogic.com>
> 
> Latest FW submission added some vxlan offload capabilities to our device.
> This patch adds the ability to connect to the vxlan NDOs and configure
> the UDP port associated with it in the HW.
> 
> The device would now be capable of performing RSS according to the
> inner headers of the vxlan packets.
> 
> Signed-off-by: Rajesh Borundia <Rajesh.Borundia@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
