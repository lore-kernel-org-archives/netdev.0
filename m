From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix sparse warnings
Date: Fri, 29 Aug 2014 20:35:23 -0700 (PDT)
Message-ID: <20140829.203523.2197369552279091093.davem@davemloft.net>
References: <1409202452-372-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaH3DfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:35:24 -0400
In-Reply-To: <1409202452-372-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 28 Aug 2014 08:07:32 +0300

> This fixes a sprase warning introduced recently by commit
> eeed018cbfa30 ("bnx2x: Add timestamping and PTP hardware clock support"),
> as well as another unrelated sparse endian issue.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks.
