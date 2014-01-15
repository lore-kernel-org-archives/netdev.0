From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Assorted mvneta fixes
Date: Tue, 14 Jan 2014 16:58:53 -0800 (PST)
Message-ID: <20140114.165853.700054361161460585.davem@davemloft.net>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, arno@natisbad.org,
	eric.dumazet@gmail.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbaAOA6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:58:55 -0500
In-Reply-To: <1389519069-1619-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Sun, 12 Jan 2014 10:31:04 +0100

> this series provides some fixes for a number of issues met with the
> mvneta driver :

These do not apply cleanly to net-next, particularly patch #5 has
different file offsets and patch #6 gets rejects.

Please respin this series, thanks.
