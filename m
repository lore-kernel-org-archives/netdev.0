From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: use new netdev_rss_key_fill() helper
Date: Wed, 19 Nov 2014 17:04:35 -0500 (EST)
Message-ID: <20141119.170435.1585388668029078505.davem@davemloft.net>
References: <1416388011-10491-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlindner@marvell.com,
	stephen@networkplumber.org, edumazet@google.com
To: ipm@chirality.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934117AbaKSWEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 17:04:38 -0500
In-Reply-To: <1416388011-10491-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>
Date: Wed, 19 Nov 2014 09:06:51 +0000

> Switch to a random RSS key rather than a fixed one.
> Using netdev_rss_key_fill helper also ensures that all ports share
> a common key.
> 
> See also commit 960fb622f85180f36d3aff82af53e2be3db2f888.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>

Applied, thank you.
