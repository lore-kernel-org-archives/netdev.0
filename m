From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bnx2x: driver updates
Date: Tue, 16 Feb 2016 20:15:00 -0500 (EST)
Message-ID: <20160216.201500.870451635223339255.davem@davemloft.net>
References: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932904AbcBQBPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:15:03 -0500
In-Reply-To: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 16 Feb 2016 18:07:56 +0200

> This series contains several changes - the biggest change is the
> addition of Geneve NDO support [allows device to perform RSS according
> to inner-headers of encapsulated packet, similar to what it does for
> vxlan]. It also extends dcbx support, as well as introducing some minor
> changes.
> 
> Dave,
> 
> Please consider applying this series to `net-next'.
> [Do notice patch #3 fails checkpatch due to consistency with existing
> HSI]

Series applied, thanks.
