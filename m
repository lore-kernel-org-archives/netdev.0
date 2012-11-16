From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2012-11-16
Date: Fri, 16 Nov 2012 13:39:04 -0500 (EST)
Message-ID: <20121116.133904.1304236642697269448.davem@davemloft.net>
References: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.wunderlich@s2003.tu-chemnitz.de,
	lindner_marek@yahoo.de, sven@narfation.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab2KPSjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 13:39:05 -0500
In-Reply-To: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Fri, 16 Nov 2012 09:49:14 +0100

> here is small set of fixes intended for net/linux-3.7.
> These patches are fixing some interoperability problems due to the features we
> added in 3.7. Mainly we have two big issues: one is preventing clients connected
> to the mesh network to contact any other hosts, caused by a not proper
> translation table handling; the second one compromises the AP isolation feature
> causing it to be completely useless, no matter it was on or off.

Pulled, thanks.
